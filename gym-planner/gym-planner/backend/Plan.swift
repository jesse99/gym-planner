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

public struct RestTime {
    public let autoStart: Bool
    
    public let secs: Int
}

public enum StartResult {
    /// Plan started up OK.
    case ok

    /// Startup the new plan instead of the original plan. Typically the new plan will be
    /// NRepMaxPlan.
    case newPlan(Plan)

    /// Arbitrary error, e.g. need to perform another exercise first.
    case error(String)
}

/// Used to tell the user how to perform sets of some activity, e.g. warmup and work sets for a barbell exercise.
public protocol Plan: Storable {
    /// This returns a name like "531" or "Light Squat".
    var name: String {get}
    
    /// This is used by Exercise to deserialize plans.
    var typeName: String {get}

    func start(_ exerciseName: String) -> StartResult
    
    /// "Light Squat".
    func label() -> String
    
    /// "200 lbs (80% of Heavy Squat)"
    func sublabel() -> String
    
    /// "Previous was 125 lbs"
    func prevLabel() -> String
    
    /// "+5 lbs, same x3, +5 lbs x4"
    func historyLabel() -> String
    
    /// Returns a struct outlining what the user should currently be doing.
    /// Note that finished must be false.
    func current() -> Activity
    
    /// How long for the user to rest after completing whatever current told him to do.
    func restSecs() -> RestTime
    
    /// If there is only one completion then just call the callback. Otherwise prompt the
    /// user and then call the callback for whichever completion the user chose.
    func completions() -> [Completion]
    
    /// Returns true if the user hasn't done anything yet.
    func atStart() -> Bool
    
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

// 531      https://www.t-nation.com/workouts/531-how-to-build-pure-strength


