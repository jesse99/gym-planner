/// Used for exercises where the user can perform as many sets as required to do a specified number of reps.
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
    
    init(_ name: String, requiredReps: Int, targetReps: Int) {
        os_log("init VariableSetsPlan for %@ and %@", type: .info, name)
        self.name = name
        self.typeName = "VariableSetsPlan"
        self.requiredReps = requiredReps
        self.targetReps = targetReps
    }
    
    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.typeName = "VariableSetsPlan"
        self.requiredReps = store.getInt("requiredReps")
        self.targetReps = store.getInt("targetReps")
        
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.reps = store.getIntArray("reps")
    }
    
    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addInt("requiredReps", requiredReps)
        store.addInt("targetReps", targetReps)
        
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addIntArray("reps", reps)
    }
    
    // Plan methods
    public let name: String
    public let typeName: String
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: VariableSetsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ exerciseName: String) -> StartResult {
        os_log("starting VariableSetsPlan for %@ and %@", type: .info, name, exerciseName)

        self.reps = []
        self.exerciseName = exerciseName
        frontend.saveExercise(exerciseName)

        return .ok
    }
    
    public func isStarted() -> Bool {
        return !exerciseName.isEmpty && !reps.isEmpty && !finished()
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        switch findWeight(exerciseName) {
        case .right(let weight):
            if weight > 0 {
                return "\(repsStr(requiredReps)) @ \(Weight.friendlyStr(weight))"
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
                return "Previous was \(rs) (\(repsStr(c)) @ \(Weight.friendlyStr(result.weight))"
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
        frontend.assert(!finished(), "VariableSetsPlan finished in current")
        
        switch findWeight(exerciseName) {
        case .right(let weight):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let suffix = weight > 0 ? " @ \(Weight.friendlyStr(weight))" : ""
            
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
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: !finished(), secs: secs)

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
            if case let .right(exercise) = findExercise(exerciseName) {
                exercise.completed = Date()
            }
            
            addResult()
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func addResult() {
        switch findWeight(exerciseName) {
        case .right(let weight):
            let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
            let title = "\(repsStr(completed)) @ \(Weight.friendlyStr(weight))"
            let result = Result(title: title, weight: weight, missed: false, reps: reps)
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


