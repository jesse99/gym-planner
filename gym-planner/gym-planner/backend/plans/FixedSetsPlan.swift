/// Sets and reps are fixed with an optional weight (set by the user).
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class FixedSetsPlan : Plan {
    struct Result: VariableWeightResult, Storable {
        let title: String   // "3x5 @ 20 lbs"
        let date: Date
        var weight: Double
        
        var primary: Bool {get {return true}}
        var missed: Bool {get {return false}}
        
        init(title: String, weight: Double) {
            self.title = title
            self.date = Date()
            self.weight = weight
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.date = store.getDate("date")
            self.weight = store.getDbl("weight")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addDate("date", date)
            store.addDbl("weight", weight)
        }
    }
    
    init(_ name: String, numSets: Int, numReps: Int) {
        os_log("init FixedSetsPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "FixedSetsPlan"
        self.numSets = numSets
        self.numReps = numReps
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? FixedSetsPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                numSets == savedPlan.numSets &&
                numReps == savedPlan.numReps
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "FixedSetsPlan"
        self.numSets = store.getInt("numSets")
        self.numReps = store.getInt("numReps")
        
        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.setIndex = store.getInt("setIndex")
        self.state = store.getObj("state", ifMissing: .waiting)
        
        switch state {
        case .waiting:
            break
        default:
            let calendar = Calendar.current
            let savedOn = store.getDate("savedOn", ifMissing: Date.distantPast)
            if !calendar.isDate(savedOn, inSameDayAs: Date()) {
                setIndex = 1
                state = .waiting
            }
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addInt("numSets", numSets)
        store.addInt("numReps", numReps)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addInt("setIndex", setIndex)
        store.addDate("savedOn", Date())
        store.addObj("state", state)
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    public var state = PlanState.waiting

    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: FixedSetsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting FixedSetsPlan for %@ and %@", type: .info, planName, exerciseName)
        self.setIndex = 1
        self.state = .started
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        frontend.saveExercise(exerciseName)
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
        switch findCurrentWeight(exerciseName) {
        case .right(let weight):
            if weight > 0.0 {
                return "\(numSets)x\(numReps) @ \(Weight.friendlyUnitsStr(weight, plural: true))"
            } else {
                return "\(numSets)x\(numReps)"
            }

        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> String {
        if case let .right(weight) = findCurrentWeight(exerciseName), weight > 0.0 {
            return makePrevLabel(history)
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        if case let .right(weight) = findCurrentWeight(exerciseName), weight > 0.0 {
            let weights = history.map {$0.weight}
            return makeHistoryLabel(Array(weights))
        } else if !history.isEmpty {
            return "x\(history.count)"
        } else {
            return ""
        }
    }
    
    public func current() -> Activity {
        var suffix = ""
        if case let .right(weight) = findCurrentWeight(exerciseName), weight > 0.0 {
            suffix = " @ \(Weight.friendlyUnitsStr(weight, plural: true))"
        }

        return Activity(
            title: "Set \(setIndex) of \(numSets)",
            subtitle: "",
            amount: "\(repsStr(numReps))\(suffix)",
            details: "",
            buttonName: "Next",
            showStartButton: true)
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            if case .finished = state {
                return RestTime(autoStart: false, secs: secs)
            } else {
                return RestTime(autoStart: true, secs: secs)
            }
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }

    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func completions() -> Completions {
        if setIndex+1 < numSets {
            return .normal([Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})])
        } else {
            return .normal([Completion(title: "Done", isDefault: true, callback: {() -> Void in self.doFinish()})])
        }
    }
    
    public func reset() {
        setIndex = 1
        state = .started
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Very simple plan where the sets and reps are fixed and weight can be set via the Options screen."
    }
    
    public func findLastWeight() -> Double? {
        return history.last?.weight
    }
    
    // Internal items
    private func doNext() {
        setIndex += 1
        state = .underway
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish() {
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        addResult()
        frontend.saveExercise(exerciseName)
    }
    
    private func addResult() {
        var title = "\(numSets)x\(numReps)"
        if case let .right(weight) = findCurrentWeight(exerciseName), weight > 0.0 {
            title += " @ \(Weight.friendlyUnitsStr(weight, plural: true))"
            let result = Result(title: title, weight: weight)
            history.append(result)
        } else {
            let result = Result(title: title, weight: 0.0)
            history.append(result)
        }
    }
    
    private let numSets: Int
    private let numReps: Int
    
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var setIndex = 1
}
