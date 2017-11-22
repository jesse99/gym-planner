/// Used for exercises where the user can perform as many sets as required to do a specified number of reps.
import Foundation
import os.log

public class VariableSetsPlan: Plan {
    struct Result: VariableWeightResult {
        let title: String   // "20 reps @ 135 lbs"
        let date: Date
        var weight: Double
        var missed: Bool
        var primary: Bool {get {return true}}
        
        let reps: [Int]
    }
    
    init(_ name: String, requiredReps: Int, targetReps: Int) {
        self.name = name
        self.requiredReps = requiredReps
        self.targetReps = targetReps
    }
    
    // Plan methods
    public let name: String
    
    public func startup(_ program: Program, _ exercise: Exercise, _ persist: Persistence) -> StartupResult {
        os_log("entering VariableSetsPlan for %@", type: .info, exercise.name)
        
        self.exercise = exercise
        self.persist = persist
        self.reps = []

        var key = ""
        do {
            // setting
            key = VariableSetsPlan.settingKey(exercise)
            var data = try persist.load(key)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            self.setting = try decoder.decode(FixedWeightSetting.self, from: data)
            
            // history
            key = VariableSetsPlan.historyKey(exercise)
            data = try persist.load(key)
            self.history = try decoder.decode([Result].self, from: data)
            
        } catch {
            os_log("Couldn't load %@: %@", type: .info, key, error.localizedDescription) // note that this can happen the first time the exercise is performed
            
            self.history = []
            switch exercise.defaultSettings {
            case .fixedWeight(let setting): self.setting = setting
            default: assert(false); abort()
            }
        }
        
        return .ok
    }
    
    public func label() -> String {
        return exercise.name
    }
    
    public func sublabel() -> String {
        if setting.weight > 0 {
            return "\(requiredReps) reps @ \(Weight.friendlyStr(setting.weight))"
        } else {
            return "\(requiredReps) reps"
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
    }
    
    public func restSecs() -> RestTime {
        return RestTime(autoStart: !finished(), secs: setting.restSecs)
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
    }
    
    public func description() -> String {
        return "Used to perform an exercise for a number of reps using as many sets as needed. Often used with pullups and chinups."
    }
    
    public func settings() -> Settings {
        return .fixedWeight(setting)
    }
    
    // Internal items
    static func settingKey(_ exercise: Exercise) -> String {
        return VariableSetsPlan.planKey(exercise) + "-setting"
    }
    
    static func historyKey(_ exercise: Exercise) -> String {
        return VariableSetsPlan.planKey(exercise) + "-history"
    }
    
    private static func planKey(_ exercise: Exercise) -> String {
        return "\(exercise.name)-fixed-reps"
    }
    
    private func do_complete(_ count: Int) {
        reps.append(count)
        
        if finished() {
            saveResult()
        }
    }
    
    private func saveResult() {
        let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
        let title = "\(completed) reps @ \(Weight.friendlyStr(setting.weight))"
        let result = Result(title: title, date: Date(), weight: setting.weight, missed: false, reps: reps)
        history.append(result)
        
        let key = VariableSetsPlan.historyKey(exercise)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(history)
            try persist.save(key, data)
        } catch {
            os_log("Error saving %@: %@", type: .error, key, error.localizedDescription)
        }
    }
    
    private func saveSetting() {
        let key = VariableSetsPlan.settingKey(exercise)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(setting)
            try persist.save(key, data)
        } catch {
            os_log("Error saving %@: %@", type: .error, key, error.localizedDescription)
        }
    }
    
    private let requiredReps: Int
    private let targetReps: Int

    private var persist: Persistence!
    private var exercise: Exercise!
    private var setting: FixedWeightSetting!
    private var history: [Result]!
    
    private var reps: [Int] = []
}


