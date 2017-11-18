/// Plan that uses a percent of the weight from another plan.
import Foundation
import os.log

private class PercentOfPlan : Plan {
    struct Sets {
        let firstWarmupPercent: Double
        let warmupReps: [Int]
        
        let workSets: Int;
        let numReps: Int
        let percent: Double
    }
    
    struct Set {
        let title: String      // "Workset 3 of 4"
        let subtitle: String   // "90% of 140 lbs"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = Weight(percent*weight, apparatus).find(.lower)
            self.numReps = numReps
            self.warmup = true

            let info = Weight(weight, apparatus).find(.closest)
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }

        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, weight: Double) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.subtitle = ""
            self.weight = Weight(weight, apparatus).find(.closest)
            self.numReps = numReps
            self.warmup = false
        }
    }
    
    struct Result: DerivedWeightResult {
        let title: String   // "135 lbs 3x5"
        let date: Date
        var weight: Double
    }
    
    init(_ exercise: Exercise, _ setting: DerivedWeightSetting, _ otherName: String, _ otherWeight: Double, _ sets: Sets, _ history: [Result], _ persist: Persistence) {
        os_log("entering PercentOfPlan for %@", type: .info, exercise.name)
        
        self.persist = persist
        self.exercise = exercise
        self.setting = setting
        self.history = history
        self.percent = sets.percent
        self.otherName = otherName
        
        let workingSetWeight = sets.percent*otherWeight;
        os_log("workingSetWeight = %.3f", type: .info, workingSetWeight)
        
        var warmupsWithBar = 0
        switch setting.apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
        default: break
        }
        
        var s: [Set] = []
        let numWarmups = warmupsWithBar + sets.warmupReps.count
        for i in 0..<warmupsWithBar {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: sets.warmupReps.first ?? 5, percent: 0.0, weight: workingSetWeight))
        }
        
        let delta = sets.warmupReps.count > 0 ? (0.9 - sets.firstWarmupPercent)/Double(sets.warmupReps.count - 1) : 0.0
        for (i, reps) in sets.warmupReps.enumerated() {
            let percent = sets.firstWarmupPercent + Double(i)*delta
            s.append(Set(setting.apparatus, phase: warmupsWithBar + i + 1, phaseCount: numWarmups, numReps: reps, percent: percent, weight: workingSetWeight))
        }
        
        for i in 0...sets.workSets {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: sets.workSets, numReps: sets.numReps, weight: workingSetWeight))
        }
        
        self.sets = s
        self.setIndex = 0
    }
    
    convenience init(_ exercise: Exercise, _ otherName: String, _ otherWeight: Double, _ sets: Sets, _ persist: Persistence) {
        var key = ""
        do {
            // setting
            key = PercentOfPlan.settingKey(exercise, otherName)
            var data = try persist.load(key)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let setting = try decoder.decode(DerivedWeightSetting.self, from: data)
            
            // history
            key = PercentOfPlan.historyKey(exercise, otherName)
            data = try persist.load(key)
            let history = try decoder.decode([Result].self, from: data)
            
            self.init(exercise, setting, otherName, otherWeight, sets, history, persist)
            
        } catch {
            os_log("Couldn't load %@: %@", type: .info, key, error.localizedDescription) // note that this can happen the first time the exercise is performed
            
            switch exercise.settings {
            case .derivedWeight(let setting): self.init(exercise, setting, otherName, otherWeight, sets, [], persist)
            default: assert(false); abort()
            }
        }
    }
    
    // Plan methods
    func label() -> String {
        return exercise.name
    }
    
    func sublabel() -> String {
        if let weight = sets.last?.weight {
            let p = Int(100.0*self.percent)
            return "\(weight.text) (\(p)% of \(otherName))"

        } else {
            let p = Int(100.0*self.percent)
            return "\(p)% of \(otherName)"
        }
    }
    
    func prevLabel() -> String {
        if let result = history.last {
            return "Previous was \(Weight.friendlyUnitsStr(result.weight))"
        } else {
            return ""
        }
    }
    
    func historyLabel() -> String {
        let weights = history.map {$0.weight}
        return makeHistoryLabel(Array(weights))
    }
    
    func current(n: Int) -> Activity {
        assert(!finished())
        
        let info = sets[setIndex].weight
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: "\(sets[setIndex].numReps) reps @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }
    
    func restSecs() -> Int {
        if !sets[setIndex].warmup {
            return setting.restSecs
        } else {
            return 0
        }
    }
    
    func completions() -> [Completion] {
        if setIndex+1 < sets.count {
            return [Completion(title: "", isDefault: true, callback: {() -> Void in self.setIndex += 1})]
        } else {
            return [
                Completion(title: "Done", isDefault: false, callback: {() -> Void in self.doFinish()})]
        }
    }
    
    func finished() -> Bool {
        return setIndex == sets.count
    }
    
    func reset() {
        setIndex = 0
    }
    
    func description() -> String {
        return "This does an exercise at a percentage of another exercises workset. It's typically used to perform a light or medium version of an exercise."
    }
    
    // Internal items
    static func settingKey(_ exercise: Exercise, _ otherName: String) -> String {
        return PercentOfPlan.planKey(exercise, otherName) + "-setting"
    }
    
    static func historyKey(_ exercise: Exercise, _ otherName: String) -> String {
        return PercentOfPlan.planKey(exercise, otherName) + "-history"
    }
    
    private static func planKey(_ exercise: Exercise, _ otherName: String) -> String {
        return "\(exercise.name)-percent-of-\(otherName)"
    }
    
    private func doFinish() {
        setIndex += 1
        assert(finished())
        
        saveResult()
    }
    
    private func saveResult() {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, date: Date(), weight: sets.last!.weight.weight)
        history.append(result)
        
        let key = PercentOfPlan.historyKey(exercise, otherName)
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
        let key = PercentOfPlan.settingKey(exercise, otherName)
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
    private let sets: [Set]
    private let percent: Double
    private let otherName: String

    private var setting: DerivedWeightSetting
    private var history: [Result]
    private var setIndex: Int
}


