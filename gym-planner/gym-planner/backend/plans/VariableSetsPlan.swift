/// Used for exercises where the user can perform as many sets as required to do a specified number of reps.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class VariableSetsPlan: Plan {
    struct Result: VariableWeightResult, Storable {
        let title: String   // "20 reps @ 135 lbs"
        let date: Date
        var weight: Double
        var missed: Bool
        var primary: Bool {get {return true}}
        
        let reps: [Int]

        init(title: String, weight: Double, missed: Bool, reps: [Int]) {
            self.title = title
            self.date = Date()
            self.weight = weight
            self.missed = missed
            self.reps = reps
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.date = store.getDate("date")
            self.weight = store.getDbl("weight")
            self.missed = store.getBool("missed")
            self.reps = store.getIntArray("reps")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addDate("date", date)
            store.addDbl("weight", weight)
            store.addBool("missed", missed)
            store.addIntArray("reps", reps)
        }
    }
    
    init(_ name: String, targetReps: Int?) {
        os_log("init VariableSetsPlan for %@ and %@", type: .info, name)
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
        
        let savedOn = store.getDate("savedOn", ifMissing: Date.distantPast)
        let calendar = Calendar.current
        if !calendar.isDate(savedOn, inSameDayAs: Date()) && !reps.isEmpty {
            reps = []
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addInt("targetReps", targetReps ?? 0)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addIntArray("reps", reps)
        store.addDate("savedOn", Date())
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: VariableSetsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> StartResult {
        os_log("starting VariableSetsPlan for %@ and %@", type: .info, planName, exerciseName)

        self.reps = []
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        frontend.saveExercise(exerciseName)

        return .ok
    }
    
    public func refresh() {
        // nothing to do
    }
    
    public func isStarted() -> Bool {
        return !exerciseName.isEmpty && !reps.isEmpty && !finished()
    }
    
    public func underway(_ workout: Workout) -> Bool {
        return isStarted() && !reps.isEmpty && workout.name == workoutName
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
        frontend.assert(!finished(), "VariableSetsPlan finished in current")
        
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
                showStartButton: true)

        case .left(let err):
            return Activity(
                title: "Set \(reps.count + 1)",
                subtitle: err,
                amount: "",
                details: "",
                buttonName: "Next",
                showStartButton: true)
        }
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: !finished(), secs: secs)

        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func completions() -> [Completion] {
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
        
        return options
    }
    
    public func atStart() -> Bool {
        return reps.isEmpty
    }
    
    public func finished() -> Bool {
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            return completed >= setting.requestedReps

        case .left(_):
            return true
        }
    }
    
    public func reset() {
        reps = []
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Used to perform an exercise for a number of reps using as many sets as needed. Often used with pullups and chinups."
    }
    
    public func findLastWeight() -> Double? {
        return history.last?.weight
    }
    
    // Internal items
    private func do_complete(_ count: Int) {
        reps.append(count)
        
        if finished() {
            if case let .right(exercise) = findExercise(exerciseName) {
                exercise.completed[workoutName] = Date()
            }
            
            addResult()
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
    
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var reps: [Int] = []
}


