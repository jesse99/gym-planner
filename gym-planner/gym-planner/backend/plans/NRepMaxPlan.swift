/// Used to find an N-rep max.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class NRepMaxPlan : Plan {
    // TODO: note that the master plan has to persist setting when this finishes so that it is saved under the right name
    // (or maybe this should take the setting key).
    
    // This is a bit of a weird plan because it uses a different plan's setting.
    init(_ name: String, workReps: Int) {
        os_log("init NRepMaxPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "NRepMaxPlan"
        self.numReps = workReps
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? NRepMaxPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                numReps == savedPlan.numReps
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "NRepMaxPlan"
        self.numReps = store.getInt("numReps")

        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.weight = store.getDbl("weight")
        self.setNum = store.getInt("setNum")
        self.state = store.getObj("state", ifMissing: .waiting)
        self.modifiedOn = store.getDate("modifiedOn", ifMissing: Date.distantPast)

        switch state {
        case .waiting:
            break
        default:
            let calendar = Calendar.current
            if !calendar.isDate(modifiedOn, inSameDayAs: Date()) {
                setNum = 1
                weight = 0.0
                state = .waiting
            }
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addInt("numReps", numReps)
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addDbl("weight", weight)
        store.addInt("setNum", setNum)
        store.addObj("state", state)
        store.addDate("modifiedOn", modifiedOn)
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    public var state = PlanState.waiting

    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: NRepMaxPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting NRepMaxPlan for %@ and %@", type: .info, planName, exerciseName)
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet

        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            self.weight = Weight(0.0, apparatus).closest().weight
            self.setNum = 1
            self.state = .started
            frontend.saveExercise(exerciseName)
            
        case .left(let err):
            self.state = .error(err)
        }

        return nil
    }
    
    public func on(_ workout: Workout) -> Bool {
        return workoutName == workout.name
    }
    
    public func refresh() {
        // nothing to do
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        return "Finding \(numReps) rep max"
    }
    
    public func prevLabel() -> String {
        return ""
    }
    
    public func historyLabel() -> String {
        return ""
    }
    
    public func current() -> Activity {
        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            let info = Weight(weight, apparatus).closest()
            return Activity(
                title: "Set \(setNum)",
                subtitle: "Finding \(numReps) rep max",
                amount: "\(repsStr(numReps)) @ \(info.text)",
                details: info.plates,
                buttonName: "Next",
                showStartButton: true,
                color: nil)

        case .left(let err):
            return Activity(
                title: "Set \(setNum)",
                subtitle: "Finding \(numReps) rep max",
                amount: "",
                details: err,
                buttonName: "Next",
                showStartButton: true,
                color: nil)
        }
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: false, secs: secs)                // no telling how hard the current set is for the user so if he wants rest he'll have to press the start timer button

        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func completions() -> Completions {
        var result: [Completion] = []
        
        result.append(Completion(title: "Done", isDefault: false, callback: {self.doFinish()}))
        
        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            var prevWeight = weight
            for _ in 0..<7 {
                let nextWeight = Weight(prevWeight, apparatus).nextWeight()
                if nextWeight > weight {    // at some point we'll run out of plates so the new weight won't be larger
                    result.append(Completion(title: "Add \(Weight.friendlyUnitsStr(nextWeight - weight))", isDefault: false, callback: {self.doNext(nextWeight)}))
                    prevWeight = nextWeight
                }
            }

        case .left(_):
            break
        }
        
        return .normal(result)
    }
    
    public func reset() {
        modifiedOn = Date()
        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            self.weight = Weight(0.0, apparatus).closest().weight
            setNum = 1
            state = .started

        case .left(let err):
            self.weight = 0.0
            setNum = 1
            state = .error(err)
        }
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Used to find a \(numReps) rep max. Other plans like LinearPlan will use this until a weight has been found."
    }
    
    public func currentWeight() -> Double? {
        return nil
    }
    
    // Internal items
    private func doNext(_ nextWeight: Double) {
        setNum += 1
        weight = nextWeight
        modifiedOn = Date()
        state = .underway
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish() {
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        modifiedOn = Date()
        state = .finished
        updateWeight()
        frontend.saveExercise(exerciseName)
    }

    private func updateWeight() {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            setting.changeWeight(weight)
            setting.stalls = 0
            os_log("set weight to = %.3f", type: .info, setting.weight)
            
        case .left(let err):
            os_log("%@ updateWeight failed: %@", type: .error, planName, err)
        }
    }

    private let numReps: Int

    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var weight: Double = 0.0
    private var setNum = 1
}
