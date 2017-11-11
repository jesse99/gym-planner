/// N (typically three) week cycle where reps drop and weight goes up. Progression happens at the
/// last cycle if the first cycle went OK.
import Foundation

// 4x5 @ 100%, 4x3 @ 105%, 4x1 @ 110%
// if 5's were ok then advance weight when finishing 1s
// if 5's were not ok then keep weight the same
// add deload for time
// see how this differs from regular 531

// TODO: Might want a version of this for younger people: less warmup sets, no rest on last warmup
private class MastersBasicCyclePlan : Plan {
    struct Execute
    {
        let numSets: Int
        let numReps: Int
        let percent: Double
    }

    struct Set
    {
        let title: String
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
    
    struct Result
    {
        let date: Date
        let cycleIndex: Int
        let missedRep: Bool

        let maxWarmupWeight: Double
        var workingSetWeight: Double
    }

    init(_ exercise: Exercise, _ setting: VariableWeightSetting, _ cycles: [Execute], _ history: [Result]) {
        assert(setting.weight > 0)  // otherwise use MaxLiftsPlan

        self.exercise = exercise
        self.setting = setting
        self.cycles = cycles
        self.history = history
        
        var warmupsWithBar = 0
        switch setting.apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
        default: break
        }

        var s: [Set] = []
        let numWarmups = 5 + warmupsWithBar
        for i in 0..<warmupsWithBar {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: 5, percent: 0.0, weight: setting.weight, warmup: true))   // could also use max reps from all the executes, but 5 is probably better than 10 or whatever
        }

        s.append(Set(setting.apparatus, phase: numWarmups-4, phaseCount: numWarmups, numReps: 5, percent: 0.5, weight: setting.weight, warmup: true))
        s.append(Set(setting.apparatus, phase: numWarmups-3, phaseCount: numWarmups, numReps: 3, percent: 0.6, weight: setting.weight, warmup: true))
        s.append(Set(setting.apparatus, phase: numWarmups-2, phaseCount: numWarmups, numReps: 1, percent: 0.7, weight: setting.weight, warmup: true))
        s.append(Set(setting.apparatus, phase: numWarmups-1, phaseCount: numWarmups, numReps: 1, percent: 0.8, weight: setting.weight, warmup: true))
        s.append(Set(setting.apparatus, phase: numWarmups, phaseCount: numWarmups,   numReps: 1, percent: 0.9, weight: setting.weight, warmup: true))
        assert(s.count == numWarmups)

        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        for i in 0...cycle.numSets {
            s.append(Set(setting.apparatus, phase: i+1, phaseCount: cycle.numSets, numReps: cycle.numReps, percent: cycle.percent, weight: setting.weight, warmup: false))
        }

        self.sets = s
        self.setIndex = 0
    }
    
    // TODO: this version should compute a key using exercise and cycles and then ask some protocol
    // for Data that it can use to de-serialize history
    convenience init(_ exercise: Exercise, _ setting: VariableWeightSetting, _ cycles: [Execute]) {
        self.init(exercise, setting, cycles, [])
    }

    func label() -> String {
        return exercise.name
    }

    /// "200 lbs (80% of Heavy Squat)"
    func sublabel() -> String {
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        let sr = "\(cycle.numSets)x\(cycle.numReps)"

        let info1 = Weight(setting.weight, setting.apparatus).find(.closest)
        if cycle.percent == 1.0 {
            return "\(sr)x\(info1.text)"
        } else {
            let info2 = Weight(cycle.percent*setting.weight, setting.apparatus).find(.closest)
            let p = String(format: "%.0f", 100.0*cycle.percent)
            return "\(sr)x\(info2.text) (\(p)% of \(info1.text)"
        }
    }

    func current(n: Int) -> Activity {
        assert(!finished())

        let info1 = Weight(setting.weight, setting.apparatus).find(.closest)
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
        
        // TODO: record result, may need to pass in a protocol to get and append results, could be json I suppose
        // TODO: update setting.weight as needed
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let lastWarmup = sets.findLast {(set) -> Bool in set.warmup}
        let result = Result(date: Date(), cycleIndex: cycleIndex, missedRep: missed, maxWarmupWeight: lastWarmup!.weight.weight, workingSetWeight: sets.last!.weight.weight)
    }

    private static func getCycle(_ cycles: [Execute], _ history: [Result]) -> Int {
        if let last = history.last {
            return (last.cycleIndex + 1) % cycles.count
        } else {
            return 0
        }
    }

    private let exercise: Exercise
    private let setting: VariableWeightSetting
    private let cycles: [Execute]
    private let history: [Result]
    
    private let sets: [Set]
    private var setIndex: Int
}

