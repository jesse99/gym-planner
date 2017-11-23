/// Advance weight after each successful workout.
import Foundation
import os.log

public class LinearPlan : Plan {
    struct Set {
        let title: String      // "Workset 3 of 4"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = Weight(percent*weight, apparatus).find(.lower)
            self.numReps = numReps
            self.warmup = true
        }
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, weight: Double) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.weight = Weight(weight, apparatus).find(.closest)
            self.numReps = numReps
            self.warmup = false
        }
    }
    
    struct Result: VariableWeightResult {
        let title: String   // "135 lbs 3x5"
        let date: Date
        var missed: Bool
        var weight: Double
        
        var primary: Bool {get {return true}}
    }
    
    init(_ name: String, firstWarmup: Double, warmupReps: [Int], workSets: Int, workReps: Int) {
        self.name = name
        self.firstWarmup = firstWarmup
        self.warmupReps = warmupReps
        self.workSets = workSets
        self.workReps = workReps
    }
    
    // Plan methods
    public let name: String
    
    public func decode(_ persist: Persistence) -> StartupResult {
        var key = ""
        do {
            // setting
            key = LinearPlan.settingKey(exercise)
            var data = try persist.load(key)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            self.setting = try decoder.decode(VariableWeightSetting.self, from: data)
            
            // history
            key = LinearPlan.historyKey(exercise)
            data = try persist.load(key)
            self.history = try decoder.decode([Result].self, from: data)
            
            if setting.weight == 0 {
                return .newPlan(NRepMaxPlan("Rep Max", workReps: workReps, setting))
            }
            
        } catch {
            os_log("Couldn't load %@: %@", type: .info, key, error.localizedDescription) // note that this can happen the first time the exercise is performed
            switch exercise.defaultSettings {
            case .variableWeight(let setting): return .newPlan(NRepMaxPlan("Rep Max", workReps: workReps, setting))
            default: return .error("\(exercise.name) isn't using variable weight")
            }
        }
    }
    
    public func startup(_ program: Program, _ exercise: Exercise, _ persist: Persistence) -> StartupResult {
        os_log("entering LinearPlan for %@", type: .info, exercise.name)
        
        self.exercise = exercise
        self.persist = persist
        
        // initialize setting and history
        var key = ""
        do {
            // setting
            key = LinearPlan.settingKey(exercise)
            var data = try persist.load(key)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            self.setting = try decoder.decode(VariableWeightSetting.self, from: data)
            
            // history
            key = LinearPlan.historyKey(exercise)
            data = try persist.load(key)
            self.history = try decoder.decode([Result].self, from: data)
            
            if setting.weight == 0 {
                return .newPlan(NRepMaxPlan("Rep Max", workReps: workReps, setting))
            }
            
        } catch {
            os_log("Couldn't load %@: %@", type: .info, key, error.localizedDescription) // note that this can happen the first time the exercise is performed
            switch exercise.defaultSettings {
            case .variableWeight(let setting): return .newPlan(NRepMaxPlan("Rep Max", workReps: workReps, setting))
            default: return .error("\(exercise.name) isn't using variable weight")
            }
            
        }
        assert(setting.weight > 0)  // otherwise use NRepMaxPlan
        
        // initialize sets
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
        let weight = deload.weight;
        
        if let percent = deload.percent {
            os_log("deloaded by %d%% (last was %d weeks ago)", type: .info, percent, deload.weeks)
        }
        os_log("weight = %.3f", type: .info, weight)
        
        var warmupsWithBar = 0
        switch setting.apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
        default: break
        }
        
        var s: [Set] = []
        let numWarmups = warmupsWithBar + warmupReps.count // TODO: some duplication here with other plans
        for i in 0..<warmupsWithBar {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: warmupReps.first ?? 5, percent: 0.0, weight: weight))
        }
        
        let delta = warmupReps.count > 0 ? (0.9 - firstWarmup)/Double(warmupReps.count - 1) : 0.0
        for (i, reps) in warmupReps.enumerated() {
            let percent = firstWarmup + Double(i)*delta
            s.append(Set(setting.apparatus, phase: warmupsWithBar + i + 1, phaseCount: numWarmups, numReps: reps, percent: percent, weight: weight))
        }
        
        for i in 0...workSets {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: workSets, numReps: workReps, weight: weight))
        }
        
        self.sets = s
        self.setIndex = 0
        return .ok
    }
    
    public func label() -> String {
        return exercise.name
    }
    
    public func sublabel() -> String {
        if let set = sets.last {
            return "\(set.numReps) reps @ \(set.weight.text)"
        } else {
            return ""
        }
    }
    
    public func prevLabel() -> String {
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads);
        if let percent = deload.percent {
            return "Deloaded by \(percent)% (last was \(deload.weeks) ago)"
            
        } else {
            return makePrevLabel(history)
        }
    }
    
    public func historyLabel() -> String {
        let weights = history.map {$0.weight}
        return makeHistoryLabel(Array(weights))
    }
    
    public func current() -> Activity {
        assert(!finished())
        
        let info = sets[setIndex].weight
        return Activity(
            title: sets[setIndex].title,
            subtitle: "",
            amount: "\(sets[setIndex].numReps) reps @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }
    
    public func restSecs() -> RestTime {
        return RestTime(autoStart: !finished() && !sets[setIndex].warmup, secs: setting.restSecs)
    }
    
    public func completions() -> [Completion] {
        if setIndex+1 < sets.count {
            return [Completion(title: "", isDefault: true, callback: {() -> Void in self.setIndex += 1})]
        } else {
            return [
                Completion(title: "Finished OK",  isDefault: true,  callback: {() -> Void in self.doFinish(false)}),
                Completion(title: "Missed a rep", isDefault: false, callback: {() -> Void in self.doFinish(true)})]
        }
    }
    
    public func atStart() -> Bool {
        return setIndex == 0
    }
    
    public func finished() -> Bool {
        return setIndex == sets.count
    }
    
    public func reset() {
        setIndex = 0
    }
    
    public func description() -> String {
        return "In this plan weights are advanced each time the lifter successfully completes an exercise. If the lifter fails to do all reps three times in a row then the weight is reduced by 10%. This plan is used by beginner programs like StrongLifts."
    }
    
    public func settings() -> Settings {
        return .variableWeight(setting)
    }
    
    // Internal items
    static func settingKey(_ exercise: Exercise) -> String {
        return LinearPlan.planKey(exercise) + "-setting"
    }
    
    static func historyKey(_ exercise: Exercise) -> String {
        return LinearPlan.planKey(exercise) + "-history"
    }
    
    private static func planKey(_ exercise: Exercise) -> String {
        return "\(exercise.name)-linear-plan"
    }
    
    private func doFinish(_ missed: Bool) {
        setIndex += 1
        assert(finished())
        
        saveResult(missed)
        handleAdvance(missed)
    }
    
    private func handleAdvance(_ missed: Bool) {
        if !missed {
            let w = Weight(setting.weight, setting.apparatus)
            setting.changeWeight(w.nextWeight())
            setting.stalls = 0
            os_log("advanced to = %.3f", type: .info, setting.weight)
            
        } else {
            setting.sameWeight()
            setting.stalls += 1
            os_log("stalled = %dx", type: .info, setting.stalls)
            
            if setting.stalls >= 3 {
                let info = Weight(0.9*setting.weight, setting.apparatus).find(.lower)
                setting.changeWeight(info.weight)
                setting.stalls = 0
                os_log("deloaded to = %.3f", type: .info, setting.weight)
            }
        }
        saveSetting()
    }
    
    private func saveResult(_ missed: Bool) {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, date: Date(), missed: missed, weight: sets.last!.weight.weight)
        history.append(result)
        
        let key = LinearPlan.historyKey(exercise)
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
        let key = LinearPlan.settingKey(exercise)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(setting)
            try persist.save(key, data)
        } catch {
            os_log("Error saving %@: %@", type: .error, key, error.localizedDescription)
        }
    }
    
    private let firstWarmup: Double
    private let warmupReps: [Int]
    private let workSets: Int;
    private let workReps: Int
    private let deloads: [Double] = [1.0, 1.0, 0.95, 0.9, 0.85];

    private var persist: Persistence!
    private var exercise: Exercise!
    private var setting: VariableWeightSetting!
    private var history: [Result]!
    private var sets: [Set]!
    
    private var setIndex: Int = 0
}


