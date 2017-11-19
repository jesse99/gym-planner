/// N (typically three) week cycle where reps drop and weight goes up. Progression happens after the
/// last cycle if the first cycle went OK.
import Foundation
import os.log

// 4x5 @ 100%, 4x3 @ 105%, 4x1 @ 110%

// TODO: Might want a version of this for younger people: less warmup sets, no rest on last warmup, less deload by time, less weight on medium/light days
public class MastersBasicCyclePlan : Plan {
    struct Execute {
        let workSets: Int
        let workReps: Int
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

            let info1 = Weight(weight, apparatus).find(.closest)
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info1.text)"
        }

        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, weight: Double) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.subtitle = ""
            self.weight = Weight(weight, apparatus).find(.closest)
            self.numReps = numReps
            self.warmup = false
        }
    }
    
    struct Result: VariableWeightResult {
        let title: String   // "135 lbs 3x5"
        let date: Date
        let cycleIndex: Int
        var missed: Bool
        var weight: Double

        var primary: Bool {get {return cycleIndex == 0}}
    }
    
    init(_ name: String, _ cycles: [Execute]) {
        self.name = name
        self.cycles = cycles
    }
    
    // Plan methods
    public let name: String
    
    public func startup(_ program: Program, _ exercise: Exercise, _ persist: Persistence) -> StartupResult {
        os_log("entering MastersBasicCyclePlan for %@", type: .info, exercise.name)
        
        self.exercise = exercise
        self.persist = persist
        
        // Initialize setting and history
        var key = ""
        do {
            // setting
            key = MastersBasicCyclePlan.settingKey(exercise)
            var data = try persist.load(key)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            self.setting = try decoder.decode(VariableWeightSetting.self, from: data)
            
            // history
            key = MastersBasicCyclePlan.historyKey(exercise)
            data = try persist.load(key)
            self.history = try decoder.decode([Result].self, from: data)
            
            if setting.weight == 0 {
                return .noWeight
            }

        } catch {
            os_log("Couldn't load %@: %@", type: .info, key, error.localizedDescription) // note that this can happen the first time the exercise is performed
            return .noWeight
        }
        assert(setting.weight > 0)  // otherwise use NRepMaxPlan

        // Initialize maxWeight and sets
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
        self.maxWeight = deload.weight;
        
        var workingSetWeight = cycle.percent*self.maxWeight;
        if let percent = deload.percent {
            os_log("deloaded by %d%% (last was %d weeks ago)", type: .info, percent, deload.weeks)
        } else if let result = MastersBasicCyclePlan.findCycleResult(history, cycleIndex), cycleIndex > 0 && result.missed {    // missed first cycle is dealt with in handleAdvance
            os_log("using previous weight since this cycle was missed last time", type: .info)
            workingSetWeight = result.weight
        }
        os_log("workingSetWeight = %.3f", type: .info, workingSetWeight)
        
        var warmupsWithBar = 0
        switch setting.apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
        default: break
        }
        
        var s: [Set] = []
        let numWarmups = 5 + warmupsWithBar
        for i in 0..<warmupsWithBar {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: 5, percent: 0.0, weight: workingSetWeight))   // could also use max reps from all the executes, but 5 is probably better than 10 or whatever
        }
        
        s.append(Set(setting.apparatus, phase: numWarmups-4, phaseCount: numWarmups, numReps: 5, percent: 0.5, weight: workingSetWeight))
        s.append(Set(setting.apparatus, phase: numWarmups-3, phaseCount: numWarmups, numReps: 3, percent: 0.6, weight: workingSetWeight))
        s.append(Set(setting.apparatus, phase: numWarmups-2, phaseCount: numWarmups, numReps: 1, percent: 0.7, weight: workingSetWeight))
        s.append(Set(setting.apparatus, phase: numWarmups-1, phaseCount: numWarmups, numReps: 1, percent: 0.8, weight: workingSetWeight))
        s.append(Set(setting.apparatus, phase: numWarmups,   phaseCount: numWarmups, numReps: 1, percent: 0.9, weight: workingSetWeight))
        assert(s.count == numWarmups)
        
        for i in 0...cycle.workSets {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: cycle.workSets, numReps: cycle.workReps, weight: workingSetWeight))
        }
        
        self.sets = s
        self.setIndex = 0
        return .ok
    }
    
    public func label() -> String {
        return exercise.name
    }

    public func sublabel() -> String {
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        let sr = "\(cycle.workSets)x\(cycle.workReps)"

        let info1 = Weight(maxWeight, setting.apparatus).find(.closest)
        if cycle.percent == 1.0 {
            return "\(sr)x\(info1.text)"
        } else {
            let info2 = sets.last!.weight
            let p = String(format: "%.0f", 100.0*cycle.percent)
            return "\(sr)x\(info2.text) (\(p)% of \(info1.text)"
        }
    }

    public func prevLabel() -> String {
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads);
        if let percent = deload.percent {
            return "Deloaded by \(percent)% (last was \(deload.weeks) ago)"

        } else {
            let index = MastersBasicCyclePlan.getCycle(cycles, history)
            let results = history.filter {$0.cycleIndex == index}
            return makePrevLabel(results)
        }
    }
    
    public func historyLabel() -> String {
        let index = MastersBasicCyclePlan.getCycle(cycles, history)
        let results = history.filter {$0.cycleIndex == index}
        let weights = results.map {$0.weight}
        return makeHistoryLabel(Array(weights))
    }
    
    public func current(n: Int) -> Activity {
        assert(!finished())

        let info = sets[setIndex].weight
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: "\(sets[setIndex].numReps) reps @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }

    public func restSecs() -> Int {
        if sets[setIndex].warmup && !sets[setIndex+1].warmup {
            return setting.restSecs/2
        } else if !sets[setIndex].warmup {
            return setting.restSecs
        } else {
            return 0
        }
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

    public func finished() -> Bool {
        return setIndex == sets.count
    }

    public func reset() {
        setIndex = 0
    }

    public func description() -> String {
        return "This is designed for lifters in their 40s and 50s. Typically it's used with three week cycles where the first week is sets of five, the second week sets of three, and the third week sets of one with the second week using 5% more weight and the third week 10% more weight. If all reps were completed for the sets of five then the weight is increased after the third week."
    }
    
    public func settings() -> Settings {
        return .variableWeight(setting)
    }
    
    // Internal items
    static func settingKey(_ exercise: Exercise) -> String {
        return MastersBasicCyclePlan.planKey(exercise) + "-setting"
    }
    
    static func historyKey(_ exercise: Exercise) -> String {
        return MastersBasicCyclePlan.planKey(exercise) + "-history"
    }
    
    private static func planKey(_ exercise: Exercise) -> String {
        return "\(exercise.name)-masters-basic-cycle"
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
        if let result = MastersBasicCyclePlan.findCycleResult(history, 0) {
            if !result.missed {
                let w = Weight(sets.last!.weight.weight, setting.apparatus)
                setting.changeWeight(w.nextWeight())
                setting.stalls = 0
                os_log("advanced to = %.3f", type: .info, setting.weight)

            } else {
                setting.sameWeight()
                setting.stalls += 1
                os_log("stalled = %d", type: .info, setting.stalls)
            }
            saveSetting()
        }
    }
    
    private static func findCycleResult(_ history: [Result], _ index: Int) -> Result? {
        for candidate in history.reversed() {
            if candidate.cycleIndex == index {
                return candidate
            }
        }
        return nil
    }

    private func saveResult(_ cycleIndex: Int, _ missed: Bool) {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, date: Date(), cycleIndex: cycleIndex, missed: missed, weight: sets.last!.weight.weight)
        history.append(result)
        
        let key = MastersBasicCyclePlan.historyKey(exercise)
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
        let key = MastersBasicCyclePlan.settingKey(exercise)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(setting)
            try persist.save(key, data)
        } catch {
            os_log("Error saving %@: %@", type: .error, key, error.localizedDescription)
        }
    }
    
    private static func getCycle(_ cycles: [Execute], _ history: [Result]) -> Int {
        if let last = history.last {
            return (last.cycleIndex + 1) % cycles.count
        } else {
            return 0
        }
    }

    private let cycles: [Execute]
    private let deloads: [Double] = [1.0, 1.0, 0.9, 0.85, 0.8];

    private var persist: Persistence!
    private var exercise: Exercise!
    private var setting: VariableWeightSetting!
    private var history: [Result]!
    private var sets: [Set]!
    private var maxWeight: Double = 0.0

    private var setIndex: Int = 0
}

