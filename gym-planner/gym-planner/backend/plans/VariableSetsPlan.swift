/// Used for exercises where the user can perform as many sets as required to do a specified number of reps.
import Foundation
import os.log

public class VariableSetsPlan: Plan {
    struct Result: VariableWeightResult, Codable {
        let title: String   // "20 reps @ 135 lbs"
        let date: Date
        var weight: Double
        var missed: Bool
        var primary: Bool {get {return true}}
        
        let reps: [Int]
    }
    
    init(_ name: String, requiredReps: Int, targetReps: Int) {
        os_log("init VariableSetsPlan for %@ and %@", type: .info, name)
        self.name = name
        self.requiredReps = requiredReps
        self.targetReps = targetReps
    }
    
    // Plan methods
    public let name: String
    
    public func start(_ exerciseName: String) -> StartResult {
        os_log("starting VariableSetsPlan for %@ and %@", type: .info, name, exerciseName)

        self.reps = []
        self.exerciseName = exerciseName
        frontend.saveExercise(exerciseName)

        return .ok
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        switch findSetting(exerciseName) {
        case .right(let setting):
            if setting.weight > 0 {
                return "\(requiredReps) reps @ \(Weight.friendlyStr(setting.weight))"
            } else {
                return "\(requiredReps) reps"
            }

        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> String {
        if let result = history.last {
            let c = result.reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let r = result.reps.map {"\($0)"}
            let rs = r.joined(separator: ", ")
            if result.weight > 0 {
                return "Previous was \(rs) (\(c) reps @ \(Weight.friendlyStr(result.weight))"
            } else {
                return "Previous was \(rs) (\(c) reps)"
            }
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        return "Target is \(targetReps) reps"
    }
    
    public func current() -> Activity {
        assert(!finished())
        
        switch findSetting(exerciseName) {
        case .right(let setting):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let suffix = setting.weight > 0 ? " @ \(Weight.friendlyStr(setting.weight))" : ""
            
            let delta = requiredReps - completed
            let amount = delta > 1 ? "1-\(delta) reps\(suffix)" : "1 rep"
            return Activity(
                title: "Set \(reps.count + 1)",
                subtitle: "",
                amount: amount,
                details: "",
                secs: nil)               // this is used for timed exercises

        case .left(let err):
            return Activity(
                title: "Set \(reps.count + 1)",
                subtitle: err,
                amount: "",
                details: "",
                secs: nil)
        }
    }
    
    public func restSecs() -> RestTime {
        switch findSetting(exerciseName) {
        case .right(let setting):
            return RestTime(autoStart: !finished(), secs: setting.restSecs)

        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func completions() -> [Completion] {
        let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
        let delta = requiredReps - completed
        
        var options: [Completion] = []
        
        for i in 0..<delta {
            let title = i == 0 ? "1 rep" : "\(i+1) reps"
            options.append(Completion(title: title, isDefault: false, callback: {() -> Void in self.do_complete(i+1)}))
        }
        
        return options
    }
    
    public func atStart() -> Bool {
        return reps.isEmpty
    }
    
    public func finished() -> Bool {
        let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
        return completed >= requiredReps
    }
    
    public func reset() {
        reps = []
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Used to perform an exercise for a number of reps using as many sets as needed. Often used with pullups and chinups."
    }
    
    // Internal items
    private func do_complete(_ count: Int) {
        reps.append(count)
        
        if finished() {
            addResult()
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func addResult() {
        switch findSetting(exerciseName) {
        case .right(let setting):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let title = "\(completed) reps @ \(Weight.friendlyStr(setting.weight))"
            let result = Result(title: title, date: Date(), weight: setting.weight, missed: false, reps: reps)
            history.append(result)

        case .left(_):
            break
        }
    }
    
    private let requiredReps: Int
    private let targetReps: Int
    
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var reps: [Int] = []
}


