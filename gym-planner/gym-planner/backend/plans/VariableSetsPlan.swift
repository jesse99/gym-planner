/// Used for exercises where the user can perform as many sets as required to do a specified number of reps.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class VariableSetsPlan: Plan {
    class Result: WeightedResult {
        let reps: [Int]

        init(title: String, weight: Double, missed: Bool, reps: [Int]) {
            self.reps = reps
            super.init(title, weight, primary: true, missed: missed)
        }
        
        required init(from store: Store) {
            self.reps = store.getIntArray("reps")
            super.init(from: store)
        }
        
        override func save(_ store: Store) {
            super.save(store)
            store.addIntArray("reps", reps)
        }
    }
    
    init(_ name: String, targetReps: Int?) {
        os_log("init VariableSetsPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "VariableSetsPlan"
        self.targetReps = targetReps
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? VariableSetsPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                targetReps == savedPlan.targetReps
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "VariableSetsPlan"
        let target = store.getInt("targetReps")
        if target > 0 {
            self.targetReps = target
        } else {
            self.targetReps = nil
        }
        
        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.reps = store.getIntArray("reps")
        self.state = store.getObj("state", ifMissing: .waiting)
        self.modifiedOn = store.getDate("modifiedOn", ifMissing: Date.distantPast)

        switch state {
        case .waiting:
            break
        default:
            let calendar = Calendar.current
            if !calendar.isDate(modifiedOn, inSameDayAs: Date()) {
                reps = []
                state = .waiting
            }
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addInt("targetReps", targetReps ?? 0)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addIntArray("reps", reps)
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
        let result: VariableSetsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting VariableSetsPlan for %@ and %@", type: .info, planName, exerciseName)

        self.reps = []
        self.state = .started
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet
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
        switch findVariableRepsSetting(exerciseName) {
            case .right(let setting):
                if setting.weight > 0 {
                    return "\(repsStr(setting.requestedReps)) @ \(Weight.friendlyStr(setting.weight))"
                } else {
                    return repsStr(setting.requestedReps)
                }

            case .left(let err):
                return err
        }
    }
    
    public func prevLabel() -> String {
        func resultToStr(_ result: Result) -> String {
            let c = result.reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let r = result.reps.map {"\($0)"}
            let rs = r.joined(separator: ", ")
            if result.weight > 0 {
                return "\(rs) (\(repsStr(c)) @ \(Weight.friendlyStr(result.weight))"
            } else {
                return "\(rs) (\(c) reps)"
            }
        }

        if history.count == 0 {
            return ""

        } else if history.count == 1 {
            return "Previous was \(resultToStr(history[history.count - 1]))"

        } else {
            return "Previous was \(resultToStr(history[history.count - 1])) and \(resultToStr(history[history.count - 2]))"
        }
    }
    
    public func historyLabel() -> String {
        return ""
    }
    
    public func current() -> Activity {
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let suffix = setting.weight > 0 ? " @ \(Weight.friendlyUnitsStr(setting.weight, plural: true))" : ""
            
            var subSuffix = ""
            if let target = targetReps {
                subSuffix = " (target is \(target))"
            }
            
            var subtitle = ""
            if reps.count > 1 {
                let a = reps.map {"\($0)"}
                let s = a.joined(separator: ", ")
                subtitle = "\(completed) of \(setting.requestedReps) (\(s))\(subSuffix)"
            } else {
                subtitle = "\(completed) of \(setting.requestedReps)\(subSuffix)"
            }
            
            let delta = setting.requestedReps - completed
            let amount = delta > 1 ? "1-\(delta) reps\(suffix)" : "1 rep"
            return Activity(
                title: "Set \(reps.count + 1)",
                subtitle: subtitle,
                amount: amount,
                details: "",
                buttonName: "Next",
                showStartButton: true,
                color: nil)

        case .left(let err):
            return Activity(
                title: "Set \(reps.count + 1)",
                subtitle: err,
                amount: "",
                details: "",
                buttonName: "Next",
                showStartButton: true,
                color: nil)
        }
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
        var options: [Completion] = []
        
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let delta = setting.requestedReps - completed
            
            for i in 0..<delta {
                let title = i == 0 ? "1 rep" : "\(i+1) reps"
                options.append(Completion(title: title, isDefault: false, callback: {() -> Void in self.do_complete(i+1)}))
            }

        case .left(_):
            options.append(Completion(title: "Done", isDefault: true, callback: {() -> Void in self.do_complete(100)})) // really shouldnt hit this case
        }
        
        return .normal(options)
    }
    
    public func reset() {
        reps = []
        modifiedOn = Date()
        state = .started
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Used to perform an exercise for a number of reps using as many sets as needed. Often used with pullups and chinups."
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
    private func do_complete(_ count: Int) {
        modifiedOn = Date()
        reps.append(count)
        
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            if completed >= setting.requestedReps {
                if case let .right(exercise) = findExercise(exerciseName) {
                    exercise.completed[workoutName] = Date()
                }
                
                state = .finished
                addResult()
            } else {
                state = .underway
            }

        case .left(let err):
            state = .error(err)
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func addResult() {
        switch findCurrentWeight(exerciseName) {
        case .right(let weight):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let title = "\(repsStr(completed)) @ \(Weight.friendlyStr(weight))"
            let result = Result(title: title, weight: weight, missed: false, reps: reps)
            history.append(result)

        case .left(_):
            break
        }
    }
    
    private let targetReps: Int?
    
    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var reps: [Int] = []
}
