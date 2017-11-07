/// Types used to tell the user how to perform an exercise, e.g. how many sets and reps to use for warmup
/// and work sets along with the weight to use for each set. This is done with the aid of a Plan which
/// manages details like progression, deloads, and manipulating volume and intensity across workouts.
import Foundation

/// Used to inform a Plan of the result of an activity.
public struct Completion {
    /// If the activity has more than one Completion then apps will typically use title to populate a popup menu or list view.
    public let title: String
    
    /// Set if the Completion is the one the user is expected to select.
    public let isDefault: Bool
    
    /// Called by apps so that the Plan can move on to whatever the user should do next.
    public let callback: () -> Void
}

/// Generic description of what the user needs to do for a particular activity within a Plan.
public struct Activity {
    /// "Warmup 3 of 6"
    public let title: String
    
    /// "60% of 300 lbs"
    public let subtitle: String
    
    /// "5 reps @ 220 lbs"
    public let amount: String
    
    /// "45 + 10 lbs"
    public let details: String
    
    /// Secs is set if the lift is timed, eg for stuff like as many reps as possible in 30s.
    public let secs: Int?
}

/// Used to tell the user how to perform sets of some activity, e.g. warmup and work sets for a barbell exercise.
public protocol Plan {
    /// "Light Squat".
    func label() -> String
    
    /// "200 lbs (80% of Heavy Squat)"
    func sublabel() -> String
    
    /// Returns a struct outlining what the user should currently be doing.
    /// Note that finished must be false.
    func current(n: Int) -> Activity
    
    /// How long for the user to rest after completing whatever current told him to do.
    func restSecs() -> Int
    
    /// If there is only one completion then just call the callback. Otherwise prompt the
    /// user and then call the callback for whichever completion the user chose.
    func completions() -> [Completion]
    
    /// Returns true if there are no more activities to perform.
    func finished() -> Bool
    
    /// Start over from the beginning.
    func reset()
    
    /// Explanation of how sets/reps, progression, and deloads work.
    func description() -> String
}

// Phrak could be LinearAMRAP
//    paramterize based on sets/reps, progression bonus amount, reps target

// GZCLP could be LinearCycleAMRAP

// BodyWeightAMRAP
//    sets/reps

// progression          how much weight to add
// failure handler      change sets/reps and/or weight and/or deload and/or rest for a bit
// deload for time          blah


// GZCLP    https://www.reddit.com/r/Fitness/comments/44hnbc/strength_training_using_the_gzcl_method_from/
// set/rep scheme           5x3+
// T1 progression           each workout, fail to do 15 reps then keep weight same and do 6x2+, then 10x1+, rest for 2-3 days and test for new 5RM, use 85% of that for new 5x3+ cycle
// T2 progression           each workout, fail to do 30 reps then drop to 3x8+, then 3x6+, then up weight and restart
// deload for progression   blah
// deload for time          blah

// https://www.reddit.com/r/Fitness/wiki/phraks-gslp
// 3x5+ (last set is AMRAP)
// add weight each workout
// if hit 10 reps on AMRAP can double added weight
// if can't hit 15 sets across all sets then deload that lift by 10%
// deload by time

/// Used to store results for executing a plan as well as settings used to configure a plan.
/// For results the only common field is "date" which is when the plan was executed.
private class Data {
    enum Value {
        case date(Date)
        case double(Double)
        case int(Int)
    }
    
    func set(_ name: String, _ value: Value) {
        data[name] = value
    }
    
    func getDate(_ name: String) -> Date? {
        if let v = data[name] {
            switch v {
            case .date(let value): return value
            default: return nil
            }
        }
        return nil
    }
    
    func getDouble(_ name: String) -> Double? {
        if let v = data[name] {
            switch v {
            case .double(let value): return value
            default: return nil
            }
        }
        return nil
    }
    
    func getInt(_ name: String) -> Int? {
        if let v = data[name] {
            switch v {
            case .int(let value): return value
            default: return nil
            }
        }
        return nil
    }
    
    var data: [String: Value] = [:]
}

// TODO: maybe this should inherit from Exercise?
private class Settings : Data {
    func lowerWeight(_ exercise: Exercise, _ weight: Double) -> Double {
        return weight   // TODO: need to use apparatus and weights
    }
}

// 4x5 @ 100%, 4x3 @ 105%, 4x1 @ 110%
// if 5's were ok then advance weight when finishing 1s
// if 5's were not ok then keep weight the same
// add deload for time
// see how this differs from regular 531
//private struct MastersBasicCyclePlan : Plan {
//    struct Execute
//    {
//        let numSets: Int
//        let numReps: Int
//        let percent: Double
//
//        init(_ sets: Int, by: Int, percent: Double)
//        {
//            self.numSets = sets
//            self.numReps = by
//            self.percent = percent
//        }
//    }
//
//    struct Set
//    {
//        let title: String
//        let numReps: Int
//        let percent: Double
//    }
//
//    init(_ exercise: Exercise, _ cycles: [Execute], _ history: [Data], _ settings: Data) {
//        self.exercise = exercise
//        self.cycles = cycles
//        self.history = history
//        self.settings = settings
//
//        var s: [Set] = []
//        var numWarmups = 5
//        if let barSets = settings.getInt("setsWithBar"), barSets > 0 {  // TODO: do we want to use bumper plates? maybe startWeight and startSets?
//            numWarmups += barSets
//            for i in 0...barSets {
//                s.append(Set(title: "Warmup \(i+1) of \(numWarmups)", numReps: 5, percent: 0.0))   // could also use max reps from all the executes, but 5 is probably better than 10 or whatever
//            }
//        }
//
//        s.append(Set(title: "Warmup \(numWarmups-4) of \(numWarmups)", numReps: 5, percent: 0.5))   // TODO: double check these
//        s.append(Set(title: "Warmup \(numWarmups-3) of \(numWarmups)", numReps: 3, percent: 0.6))
//        s.append(Set(title: "Warmup \(numWarmups-2) of \(numWarmups)", numReps: 1, percent: 0.7))
//        s.append(Set(title: "Warmup \(numWarmups-1) of \(numWarmups)", numReps: 1, percent: 0.8))
//        s.append(Set(title: "Warmup \(numWarmups) of \(numWarmups)",   numReps: 1, percent: 0.9))
//
//        let cycle = getCycle()
//        for i in 0...cycle.numSets {
//            s.append(Set(title: "Workset \(i+1) of \(cycle.numSets)", numReps: cycle.numReps, percent: cycle.percent))
//        }
//
//        self.sets = s
//    }
//
//    func label() -> String {
//        return exercise.name
//    }
//
//    func sublabel() -> String {
//        if let weight = settings.getDouble("weight"), weight > 0 {
//            let cycle = getCycle()
//            let a = "\(cycle.numSets)x\(cycle.numReps)"
//            if cycle.percent == 1.0 {
//                let x = weightToStr(settings, weight)
//                return "\(a)x\(x)"
//            } else {
//                let x = weightToStr(settings, cycle.percent*weight)
//                let y = String(format: "%.0f", 100.0*cycle.percent)
//                let z = weightToStr(settings, weight)
//                return "\(a)x\(x) (\(y)% of \(z)"
//            }
//        } else {
//            return ""
//        }
//    }
//
//    func current(n: Int) -> Activity {
//        assert(!finished())
//
//        let weight = settings.getDouble("weight")!  // TODO: is ! ok?
//        let p = String(format: "%.0f", 100.0*sets[index].percent)
//        let w1 = weightToStr(settings, weight)
//        let w2 = weightToStr(settings, sets[index].percent*weight)  // TODO: here (and elsewhere) need to get lower/closest
//        return Activity(
//            title: sets[index].title,
//            subtitle: "\(p)% of \(w1)",
//            amount: "\(sets[index].numReps) @ \(w2)",
//            details: "25 + 10 lbs",         // TODO: set this
//            secs: nil)                      // TODO: set this for last warmup and workset
//    }
//
//    func restSecs() -> Int {
//        // TODO: this should be zero for all but the last warmup, last warmup should be something like half normal rest time
//        return settings.getInt("rest") ?? 180
//    }
//
//    func completions() -> [Completion] {
//        return []
//    }
//
//    func finished() -> Bool {
//        return true
//    }
//
//    func reset() {
//
//    }
//
//    func description() -> String {
//        return ""
//    }
//
//    private func getCycle() -> Execute {
//
//    }
//
//    let exercise: Exercise
//    let cycles: [Execute]
//    let history: [Data]
//    let settings: Data
//
//    let sets: [Set]
//    var index: Int
//}
//
