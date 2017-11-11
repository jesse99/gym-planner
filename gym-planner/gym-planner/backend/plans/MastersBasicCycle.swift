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
        
        init(_ exercise: Exercise, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double, warmup: Bool) {
            if warmup {
                self.title = "Warmup \(phase) of \(phaseCount)"
                self.weight = Weight(percent*weight).find(.lower, exercise)
            } else {
                self.title = "Workset \(phase) of \(phaseCount)"
                self.weight = Weight(percent*weight).find(.closest, exercise)
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

    init(_ exercise: Exercise, _ cycles: [Execute], _ history: [Result], warmupsWithBar: Int) {
        switch exercise.modality {
        case .weights(apparatus: let apparatus, restSecs: let restSecs, weight: let weight):
            assert(weight > 0)  // otherwise use MaxLiftsPlan
            self.apparatus = apparatus
            self.restTime = restSecs
            self.weight = weight
        default: assert(false); abort()  // TODO: need to make sure that this is only used for the right exercises, eg Weight will blow up if canFind is false
        }

        self.exercise = exercise
        self.cycles = cycles
        self.history = history

        var s: [Set] = []
        let numWarmups = 5 + warmupsWithBar
        for i in 0..<warmupsWithBar {
            s.append(Set(exercise, phase: i+1, phaseCount: numWarmups, numReps: 5, percent: 0.0, weight: weight, warmup: true))   // could also use max reps from all the executes, but 5 is probably better than 10 or whatever
        }

        s.append(Set(exercise, phase: numWarmups-4, phaseCount: numWarmups, numReps: 5, percent: 0.5, weight: weight, warmup: true))
        s.append(Set(exercise, phase: numWarmups-3, phaseCount: numWarmups, numReps: 3, percent: 0.6, weight: weight, warmup: true))
        s.append(Set(exercise, phase: numWarmups-2, phaseCount: numWarmups, numReps: 1, percent: 0.7, weight: weight, warmup: true))
        s.append(Set(exercise, phase: numWarmups-1, phaseCount: numWarmups, numReps: 1, percent: 0.8, weight: weight, warmup: true))
        s.append(Set(exercise, phase: numWarmups, phaseCount: numWarmups,   numReps: 1, percent: 0.9, weight: weight, warmup: true))
        assert(s.count == numWarmups)

        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        for i in 0...cycle.numSets {
            s.append(Set(exercise, phase: i+1, phaseCount: cycle.numSets, numReps: cycle.numReps, weight: cycle.percent*weight, warmup: false))
        }

        self.sets = s
        self.setIndex = 0
    }
    
    // TODO: this version should compute a checksum using exercise and cycles and then ask some protocol
    // for Data that it can use to de-serialize history
    convenience init(_ exercise: Exercise, _ cycles: [Execute], warmupsWithBar: Int) {
        self.init(exercise, cycles, [], warmupsWithBar: warmupsWithBar)
    }

    func label() -> String {
        return exercise.name
    }

    /// "200 lbs (80% of Heavy Squat)"
    func sublabel() -> String {
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        let sr = "\(cycle.numSets)x\(cycle.numReps)"

        let info1 = Weight(weight).find(.closest, exercise)
        if cycle.percent == 1.0 {
            return "\(sr)x\(info1.text)"
        } else {
            let info2 = Weight(cycle.percent*weight).find(.closest, exercise)
            let p = String(format: "%.0f", 100.0*cycle.percent)
            return "\(sr)x\(info2.text) (\(p)% of \(info1.text)"
        }
    }

    func current(n: Int) -> Activity {
        assert(!finished())

        let info1 = Weight(weight).find(.closest, exercise)
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
            return restTime/2
        } else if !sets[setIndex].warmup {
            return restTime
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
    private let cycles: [Execute]
    private let history: [Result]
    private let apparatus: Apparatus
    private let restTime: Int
    private let weight: Double

    private let sets: [Set]
    private var setIndex: Int
}

