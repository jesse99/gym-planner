/// Used for exercises where the user can perform as many sets as required to do a specified number of reps.
import Foundation
import os.log

private class FixedRepsPlan: Plan {
    struct Result: VariableWeightResult {
        let title: String   // "20 reps @ 135 lbs"
        let date: Date
        var weight: Double
        var missed: Bool
        var primary: Bool {get {return true}}
        
        let reps: [Int]
    }
    
    init(_ exercise: Exercise, _ setting: FixedWeightSetting, _ history: [Result], _ persist: Persistence, requiredReps: Int, targetReps: Int) {
        os_log("entering FixedRepsPlan for %@", type: .info, exercise.name)
        
        self.persist = persist
        self.exercise = exercise
        self.setting = setting
        self.history = history
        self.requiredReps = requiredReps
        self.targetReps = targetReps
    }
    
    convenience init(_ exercise: Exercise, _ persist: Persistence, requiredReps: Int, targetReps: Int) {
        var key = ""
        do {
            // setting
            key = FixedRepsPlan.settingKey(exercise)
            var data = try persist.load(key)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let setting = try decoder.decode(FixedWeightSetting.self, from: data)
            
            // history
            key = FixedRepsPlan.historyKey(exercise)
            data = try persist.load(key)
            let history = try decoder.decode([Result].self, from: data)
            
            self.init(exercise, setting, history, persist, requiredReps: requiredReps, targetReps: targetReps)
            
        } catch {
            os_log("Couldn't load %@: %@", type: .info, key, error.localizedDescription) // note that this can happen the first time the exercise is performed
            
            switch exercise.settings {
            case .fixedWeight(let setting): self.init(exercise, setting, [], persist, requiredReps: requiredReps, targetReps: targetReps)
            default: assert(false); abort()
            }
        }
    }
    
    // Plan methods
    func label() -> String {
        return exercise.name
    }
    
    func sublabel() -> String {
        if setting.weight > 0 {
            return "\(requiredReps) reps @ \(Weight.friendlyStr(setting.weight))"
        } else {
            return "\(requiredReps) reps"
        }
    }
    
    func prevLabel() -> String {
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
    
    func historyLabel() -> String {
        return "Target is \(targetReps) reps"
    }
    
    func current(n: Int) -> Activity {
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
    
    func restSecs() -> Int {
        return setting.restSecs
    }
    
    func completions() -> [Completion] {
        let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
        let delta = requiredReps - completed
        
        var options: [Completion] = []
        
        for i in 0..<delta {
            let title = i == 0 ? "1 rep" : "\(i+1) reps"
            options.append(Completion(title: title, isDefault: false, callback: {() -> Void in self.do_complete(i+1)}))
        }
        
        return options
    }
    
    func finished() -> Bool {
        let completed = reps.reduce(0, {(sum, rep) -> Int in sum + rep})
        return completed >= requiredReps
    }
    
    func reset() {
        reps = []
    }
    
    func description() -> String {
        return "Used to perform an exercise for a number of reps using as many sets as needed. Often used with pullups and chinups."
    }
    
    // Internal items
    static func settingKey(_ exercise: Exercise) -> String {
        return FixedRepsPlan.planKey(exercise) + "-setting"
    }
    
    static func historyKey(_ exercise: Exercise) -> String {
        return FixedRepsPlan.planKey(exercise) + "-history"
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
        
        let key = FixedRepsPlan.historyKey(exercise)
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
        let key = FixedRepsPlan.settingKey(exercise)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(setting)
            try persist.save(key, data)
        } catch {
            os_log("Error saving %@: %@", type: .error, key, error.localizedDescription)
        }
    }
    
    private let persist: Persistence
    private let exercise: Exercise
    private let requiredReps: Int
    private let targetReps: Int
    
    private var setting: FixedWeightSetting
    private var history: [Result]
    private var reps: [Int] = []
}


