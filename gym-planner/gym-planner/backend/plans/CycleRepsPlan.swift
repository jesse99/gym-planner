/// Advances reps to a max and then advances weight.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class CycleRepsPlan : Plan {
    struct Set: Storable {
        let title: String      // "Set 3 of 4"
        let amount: String     // "8-12 reps @ 200 lbs"
        
        init(set: Int, numSets: Int, minReps: Int, maxReps: Int, weight: Double) {
            self.title = "Set \(set) of \(numSets)"
            
            let prefix = minReps != maxReps ? "\(minReps)-\(maxReps) reps" : repsStr(maxReps)
            self.amount = "\(prefix) @ \(Weight.friendlyUnitsStr(weight, plural: true))"
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.amount = store.getStr("amount")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addStr("amount", amount)
        }
    }
    
    class Result: WeightedResult {
        init(numSets: Int, numReps: Int, weight: Double) {
            self.numSets = numSets
            self.numReps = numReps
            
            let title = "\(numSets)x\(numReps) @ \(Weight.friendlyUnitsStr(weight, plural: true))"
            super.init(title, weight, primary: true, missed: false)
        }
        
        required init(from store: Store) {
            self.numSets = store.getInt("numSets")
            self.numReps = store.getInt("numReps")
            super.init(from: store)
        }
        
        public override func save(_ store: Store) {
            super.save(store)
            store.addInt("numSets", numSets)
            store.addInt("numReps", numReps)
        }
        
        internal override func updatedWeight(_ newWeight: Weight.Info) {
            title = "\(numSets)x\(numReps) @ \(newWeight.text)"
        }
        
        let numSets: Int
        let numReps: Int
    }
    
    init(_ name: String, numSets: Int, minReps: Int, maxReps: Int) {
        os_log("init CycleRepsPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "CycleRepsPlan"
        self.numSets = numSets
        self.minReps = minReps
        self.maxReps = maxReps
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? CycleRepsPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                numSets == savedPlan.numSets &&
                minReps == savedPlan.minReps &&
                maxReps == savedPlan.maxReps
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "CycleRepsPlan"
        self.numSets = store.getInt("numSets")
        self.minReps = store.getInt("minReps")
        self.maxReps = store.getInt("maxReps")
        
        self.workoutName = store.getStr("workoutName")
        self.exerciseName = store.getStr("exerciseName")
        self.sets = store.getObjArray("sets")
        self.history = store.getObjArray("history")
        self.setIndex = store.getInt("setIndex")
        self.state = store.getObj("state")
        self.modifiedOn = store.getDate("modifiedOn")
        
        switch state {
        case .waiting:
            break
        default:
            let calendar = Calendar.current
            if !calendar.isDate(modifiedOn, inSameDayAs: Date()) {
                sets = []
                setIndex = 0
                state = .waiting
            }
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addInt("numSets", numSets)
        store.addInt("minReps", minReps)
        store.addInt("maxReps", maxReps)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("sets", sets)
        store.addObjArray("history", history)
        store.addInt("setIndex", setIndex)
        store.addDate("modifiedOn", modifiedOn)
        store.addObj("state", state)
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    public var state = PlanState.waiting
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: CycleRepsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting CycleRepsPlan for %@ and %@", type: .info, planName, exerciseName)
        self.sets = []
        self.setIndex = 0
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet
        
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            self.state = .started
            buildSets(setting)
            frontend.saveExercise(exerciseName)
            
        case .left(let err):
            self.state = .error(err)
        }
        
        return nil
    }
    
    public func getHistory() -> [BaseResult] {
        return history
    }
    
    public func deleteHistory(_ index: Int) {
        history.remove(at: index)
        frontend.saveExercise(exerciseName)
    }
    
    public func on(_ workout: Workout) -> Bool {
        return workoutName == workout.name
    }
    
    public func refresh() {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            buildSets(setting)
        case .left(_):
            break
        }
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    private let defaultRequested = 6
    
    public func sublabel() -> String {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let requested = setting.reps ?? defaultRequested
            let prefix = requested != maxReps ? "\(requested)-\(maxReps) reps" : repsStr(maxReps)
            return "\(numSets)x\(prefix) @ \(Weight.friendlyUnitsStr(setting.weight, plural: true))"
        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> String {
        if let last = history.last {
            return last.title
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        if let last = history.last, last.getWeight() > 0.0 {
            var weights = Array(history.map {$0.getWeight()})
            if case .right(let setting) = findVariableWeightSetting(exerciseName) {
                weights.append(setting.weight)
            }
            return makeHistoryLabel(weights)
        } else {
            return ""
        }
    }
    
    public func current() -> Activity {
        return Activity(
            title: sets[setIndex].title,
            subtitle: "",
            amount: sets[setIndex].amount,
            details: "",
            buttonName: "Next",
            showStartButton: true,
            color: nil)
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            if case .finished = state {
                return RestTime(autoStart: false, secs: secs)
            } else {
                return RestTime(autoStart: setIndex > 0, secs: secs)
            }
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func completions() -> Completions {
        if setIndex+1 < sets.count {
            return .normal([Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})])
        } else {
            if case .right(let setting) = findVariableWeightSetting(exerciseName), let requested = setting.reps {
                var completions: [Completion] = []
                let minimum = max(requested - 3, 1)
                for reps in minimum..<maxReps {
                    completions.append(Completion(title: "Did \(repsStr(reps))",  isDefault: reps == requested,  callback: {() -> Void in self.doFinish(requested, reps)}))
                }
                // This is outside the loop to handle the odd case where requested > max.
                completions.append(Completion(title: "Did \(repsStr(maxReps))",  isDefault: maxReps == requested,  callback: {() -> Void in self.doFinish(requested, self.maxReps)}))
                return .normal(completions)
                
            } else {
                return .normal([Completion(title: "Done", isDefault: false, callback: {() -> Void in self.doFinish(1, self.defaultRequested)})])
            }
        }
    }
    
    public func reset() {
        setIndex = 0
        modifiedOn = Date()
        state = .started
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Reps advance from a min to a max. Then weight is advanced and reps drop back to the min. Often used for accessories like a Lat Pulldown."
    }
    
    public func currentWeight() -> Double? {
        switch findCurrentWeight(exerciseName) {
        case .right(let weight):
            return weight
        case .left(_):
            return nil
        }
    }
    
    // Internal items
    private func doNext() {
        setIndex += 1
        modifiedOn = Date()
        state = .underway
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish(_ requested: Int, _ reps: Int) {
        modifiedOn = Date()
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        if reps >= requested {
            handleAdvance(reps)
        }
        addResult(reps)
        frontend.saveExercise(exerciseName)
    }
    
    private func handleAdvance(_ newReps: Int) {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let oldReps = setting.reps ?? 0
            setting.reps = newReps
            if newReps > maxReps {
                setting.reps = minReps

                let oldWeight = setting.weight
                let w = Weight(setting.weight, setting.apparatus)
                setting.changeWeight(w.nextWeight())
                os_log("advanced from %.3f to %.3f lbs", type: .info, oldWeight, setting.weight)
            } else {
                os_log("advanced from %d to %d reps", type: .info, oldReps, newReps)
            }
            
        case .left(let err):
            // Not sure if this can happen, maybe if the user edits the program after the plan starts.
            os_log("%@ advance failed: %@", type: .error, planName, err)
        }
    }
    
    private func addResult(_ reps: Int) {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let result = Result(numSets: numSets, numReps: reps, weight: setting.weight)
            history.append(result)
        case .left(_):
            break
        }
    }
    
    private func buildSets(_ setting: VariableWeightSetting) {
        let weight = setting.weight
        os_log("weight = %.3f", type: .info, weight)
        
        sets = []
        for i in 0..<numSets {
            let requested = setting.reps ?? defaultRequested
            sets.append(Set(set: i+1, numSets: numSets, minReps: requested, maxReps: maxReps, weight: setting.weight))
        }
    }
    
    private let numSets: Int
    private let minReps: Int
    private let maxReps: Int
    
    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex = 0
}

