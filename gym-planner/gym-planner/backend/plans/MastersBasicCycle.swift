/// N (typically three) week cycle where reps drop and weight goes up. Progression happens at the
/// last cycle if the first cycle went OK.
import Foundation

// 4x5 @ 100%, 4x3 @ 105%, 4x1 @ 110%
// if 5's were ok then advance weight when finishing 1s
// if 5's were not ok then keep weight the same
// add deload for time
// see how this differs from regular 531

// TODO: Might want a version of this for younger people: less warmup sets, no rest on last warmup, less deload by time, less weight on medium/light days
private class MastersBasicCyclePlan : Plan {
    struct Execute
    {
        let numSets: Int
        let numReps: Int
        let percent: Double
    }

    struct Set
    {
        let title: String   // "Workset 3 of 4"
        let numReps: Int
        let weight: Weight.Info
        let percent: Double
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double, warmup: Bool) {
            if warmup {
                self.title = "Warmup \(phase) of \(phaseCount)"
                self.weight = Weight(percent*weight, apparatus).find(.lower)
            } else {
                self.title = "Workset \(phase) of \(phaseCount)"
                self.weight = Weight(percent*weight, apparatus).find(.closest)
            }
            self.numReps = numReps
            self.percent = percent
            self.warmup = warmup
        }
    }
    
    struct Result: VariableWeightResult
    {
        let title: String   // "135 lbs 3x5"
        let date: Date
        let cycleIndex: Int
        var missed: Bool
        var weight: Double

        var primary: Bool {get {return cycleIndex == 0}}
    }
    
    init(_ exercise: Exercise, _ setting: VariableWeightSetting, _ cycles: [Execute], _ history: [Result], _ persist: Persistence) {
        assert(setting.weight > 0)  // otherwise use MaxLiftsPlan

        self.persist = persist
        self.exercise = exercise
        self.setting = setting
        self.cycles = cycles
        self.history = history
        
        self.workingSetWeight = deloadByDate(setting.weight, setting.updatedWeight, deloads).weight;
        
        var warmupsWithBar = 0
        switch setting.apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
        default: break
        }

        var s: [Set] = []
        let numWarmups = 5 + warmupsWithBar
        for i in 0..<warmupsWithBar {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: 5, percent: 0.0, weight: workingSetWeight, warmup: true))   // could also use max reps from all the executes, but 5 is probably better than 10 or whatever
        }

        s.append(Set(setting.apparatus, phase: numWarmups-4, phaseCount: numWarmups, numReps: 5, percent: 0.5, weight: workingSetWeight, warmup: true))
        s.append(Set(setting.apparatus, phase: numWarmups-3, phaseCount: numWarmups, numReps: 3, percent: 0.6, weight: workingSetWeight, warmup: true))
        s.append(Set(setting.apparatus, phase: numWarmups-2, phaseCount: numWarmups, numReps: 1, percent: 0.7, weight: workingSetWeight, warmup: true))
        s.append(Set(setting.apparatus, phase: numWarmups-1, phaseCount: numWarmups, numReps: 1, percent: 0.8, weight: workingSetWeight, warmup: true))
        s.append(Set(setting.apparatus, phase: numWarmups, phaseCount: numWarmups,   numReps: 1, percent: 0.9, weight: workingSetWeight, warmup: true))
        assert(s.count == numWarmups)

        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        for i in 0...cycle.numSets {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: cycle.numSets, numReps: cycle.numReps, percent: cycle.percent, weight: workingSetWeight, warmup: false))
        }

        self.sets = s
        self.setIndex = 0
    }
    
    convenience init(_ exercise: Exercise, _ cycles: [Execute], _ persist: Persistence) {
        var key = ""
        do {
            key = MastersBasicCyclePlan.settingKey(exercise, cycles)
            var data = try persist.load(key)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let setting = try decoder.decode(VariableWeightSetting.self, from: data)
            
            key = MastersBasicCyclePlan.historyKey(exercise, cycles)
            data = try persist.load(key)
            let history = try decoder.decode([Result].self, from: data)
            
            self.init(exercise, setting, cycles, history, persist)
            
        } catch {
            print("Couldn't load \(key): \(error)") // note that this can happen the first time the exercise is performed
            
            switch exercise.settings {
            case .variableWeight(let setting): self.init(exercise, setting, cycles, [], persist)
            default: assert(false); abort()
            }
        }
    }
    
    static func settingKey(_ exercise: Exercise, _ cycles: [Execute]) -> String {
        return MastersBasicCyclePlan.planKey(exercise, cycles) + "-setting"
    }
    
    static func historyKey(_ exercise: Exercise, _ cycles: [Execute]) -> String {
        return MastersBasicCyclePlan.planKey(exercise, cycles) + "-history"
    }
    
    private static func planKey(_ exercise: Exercise, _ cycles: [Execute]) -> String {
        let cycleLabels = cycles.map {"\($0.numSets)x\($0.numReps)x\($0.percent)"}
        let cycleStr = cycleLabels.joined(separator: "-")
        return "\(exercise.name)-\(cycleStr)"
    }
    
    func label() -> String {
        return exercise.name
    }

    func sublabel() -> String {
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        let sr = "\(cycle.numSets)x\(cycle.numReps)"

        let info1 = Weight(workingSetWeight, setting.apparatus).find(.closest)
        if cycle.percent == 1.0 {
            return "\(sr)x\(info1.text)"
        } else {
            let info2 = Weight(cycle.percent*workingSetWeight, setting.apparatus).find(.closest)
            let p = String(format: "%.0f", 100.0*cycle.percent)
            return "\(sr)x\(info2.text) (\(p)% of \(info1.text)"
        }
    }

    func prevLabel() -> String {
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads);
        if let percent = deload.percent {
            return "Deloaded by \(percent)% (last was \(deload.weeks) ago)"

        } else {
            let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
            if let result = findCycleResult(cycleIndex) {
                let w = Weight(result.weight, setting.apparatus)
                if !result.missed {
                    return "Previous was \(w.find(.closest).text)"
                } else {
                    return "Previous missed \(w.find(.closest).text)"
                }
            } else {
                return ""
            }
        }
    }
    
    func historyLabel() -> String {
        let index = MastersBasicCyclePlan.getCycle(cycles, history)
        let results = history.filter {$0.cycleIndex == index}
        let weights = results.map {$0.weight}
        return makeHistoryLabel(Array(weights))
    }
    
    func current(n: Int) -> Activity {
        assert(!finished())

        let info1 = Weight(workingSetWeight, setting.apparatus).find(.closest)
        let info2 = sets[setIndex].weight
        
        let p = String(format: "%.0f", 100.0*sets[setIndex].percent)
        return Activity(
            title: sets[setIndex].title,
            subtitle: "\(p)% of \(info1.text)",
            amount: "\(sets[setIndex].numReps) @ \(info2.text)",
            details: info2.plates,
            secs: nil)               // this is used for timed exercises
    }

    func restSecs() -> Int {
        if sets[setIndex].warmup && !sets[setIndex+1].warmup {
            return setting.restSecs/2
        } else if !sets[setIndex].warmup {
            return setting.restSecs
        } else {
            return 0
        }
    }

    func completions() -> [Completion] {
        if setIndex+1 < sets.count {
            return [Completion(title: "", isDefault: true, callback: {() -> Void in self.setIndex += 1})]
        } else {
            return [Completion(title: "Completed all reps", isDefault: true, callback: {() -> Void in self.doFinish(false)}),
            Completion(title: "Missed a rep", isDefault: false, callback: {() -> Void in self.doFinish(true)})]
        }
    }

    func finished() -> Bool {
        return setIndex == sets.count
    }

    func reset() {
        setIndex = 0
    }

    func description() -> String {
        return "This is designed for lifters in their 40s and 50s or lifters with a demanding physical job or sport. Typically it's used with three week cycles where the first week is sets of five, the second week sets of three, and the third week sets of one with the second week using 5% more weight and the third week 10% more weight. If all reps were completed for the sets of five then the weight is increased after the third week."
    }
    
    private func doFinish(_ missed: Bool) {
        setIndex += 1
        assert(finished())
        
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        saveResult(cycleIndex, missed)
        
        if cycleIndex == cycles.count-1 {
            handleAdvance()
        }
    }
    
    private func handleAdvance() {
        if let result = findCycleResult(0) {
            if !result.missed {
                let w = Weight(sets.last!.weight.weight, setting.apparatus)
                setting.changeWeight(w.nextWeight())
                setting.stalls = 0

            } else {
                setting.sameWeight()
                setting.stalls += 1
            }
            saveSetting()
        }
    }
    
    private func findCycleResult(_ index: Int) -> Result? {
        for candidate in history.reversed() {
            if candidate.cycleIndex == index {
                return candidate
            }
        }
        return nil
    }

    private func saveResult(_ cycleIndex: Int, _ missed: Bool) {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0: 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, date: Date(), cycleIndex: cycleIndex, missed: missed, weight: sets.last!.weight.weight)
        history.append(result)
        
        let key = MastersBasicCyclePlan.historyKey(exercise, cycles)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(history)
            try persist.save(key, data)
        } catch {
            print("Error saving \(key): \(error)")
        }
    }
    
    private func saveSetting() {
        let key = MastersBasicCyclePlan.settingKey(exercise, cycles)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(setting)
            try persist.save(key, data)
        } catch {
            print("Error saving \(key): \(error)")
        }
    }
    
    private static func getCycle(_ cycles: [Execute], _ history: [Result]) -> Int {
        if let last = history.last {
            return (last.cycleIndex + 1) % cycles.count
        } else {
            return 0
        }
    }

    private let persist: Persistence
    private let exercise: Exercise
    private let cycles: [Execute]
    private let sets: [Set]
    private let deloads: [Double] = [1.0, 1.0, 0.9, 0.85, 0.8];
    private let workingSetWeight: Double    // setting.weight unless a deload happened

    private var setting: VariableWeightSetting
    private var history: [Result]
    private var setIndex: Int
}

