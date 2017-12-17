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

public typealias CardioCompletion = (_ mins: Int, _ calories: Int) -> Void

public enum Completions {
    case normal([Completion])
    case cardio(CardioCompletion)
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
        
    /// Usually "Next". If empty then GUIs should auto-complete once restSecs expire.
    public let buttonName: String
    
    /// Usually true
    public let showStartButton: Bool
    
    /// X11 background color name. Note that case is ignored.
    public let color: String?
}

public struct RestTime {
    public let autoStart: Bool
    
    public let secs: Int
}

/// Lifecycle for plans. Typically plans transition from waiting -> started -> underway -> finished
/// though some plans skip underway.
public enum PlanState {
    /// The plan has been initialized but not started yet. Note that plans also enter this state
    /// when they are loaded from disk if it's been more than a day since they were started.
    case waiting
    
    /// Start has been called and the plan was able to start OK but the user hasn't advanced within
    /// the plan (e.g. by pressing the Next button).
    case started
    
    /// The plan was in started but the user has advanced past started, but isn't yet finished.
    case underway
    
    /// The user has advanced so far that there is nothing left to do for this iteration of the plan.
    case finished
    
    /// Start was called but the plan cannot be executed until another exercise is executed. For example,
    /// PercentOfPlan requires that its base plan be executed before it can execute.
    case blocked
    
    /// Start was called but there was some fatal error that prevents the plan from executing. For example,
    /// PercentOfPlan cannot find the base plan.
    case error(String)
}

/// Used to tell the user how to perform sets of some activity, e.g. warmup and work sets for a barbell exercise.
public protocol Plan: Storable {
    /// This returns a name like "531" or "Light Squat".
    var planName: String {get}
    
    /// This is used by Exercise to deserialize plans.
    var typeName: String {get}
    
    var state: PlanState {get}

    func shouldSync(_ savedPlan: Plan) -> Bool
    
    func clone() -> Plan

    /// If the plan requires another plan to be executed then the new plan will be returned
    /// and state will be set to blocked.
    func start(_ workout: Workout, _ exerciseName: String) -> Plan?
    
    /// Returns true if the plan was started for workout.
    func on(_ workout: Workout) -> Bool
    
    /// Called when settings change.
    func refresh()
    
    /// "Light Squat".
    func label() -> String
    
    /// "200 lbs (80% of Heavy Squat)"
    func sublabel() -> String
    
    /// "Previous was 125 lbs"
    func prevLabel() -> String
    
    /// "+5 lbs, same x3, +5 lbs x4"
    func historyLabel() -> String
    
    /// Returns a struct outlining what the user should currently be doing.
    func current() -> Activity
    
    /// How long for the user to rest after completing whatever current told him to do.
    func restSecs() -> RestTime
    
    /// Which sound to play when done resting. Usually kSystemSoundID_Vibrate.
    func restSound() -> UInt32
    
    /// If there is only one completion then just call the callback. Otherwise prompt the
    /// user and then call the callback for whichever completion the user chose.
    func completions() -> Completions
    
    /// Start over from the beginning.
    func reset()
        
    /// Explanation of how sets/reps, progression, and deloads work.
    func description() -> String

    func getHistory() -> [BaseResult]
    func deleteHistory(_ index: Int)
    
    /// Returns the weight the user is expected to lift. Note that this is the base-line weight, e.g.
    /// for a plan with cycles it'll typically be the weight for the first cycle.
    func currentWeight() -> Double?
}

extension PlanState: Storable {
    public init(from store: Store) {
        let name = store.getStr("plan-state")
        switch name {
        case "waiting": self = .waiting
        case "started": self = .started
        case "underway": self = .underway
        case "finished": self = .finished
        case "blocked": self = .blocked
        case "error": self = .error(store.getStr("plan-state-err"))
            
        default: frontend.assert(false, "loading program had unknown plan state: \(name)"); abort()
        }
    }
    
    public func save(_ store: Store) {
        switch self {
        case .waiting: store.addStr("plan-state", "waiting")
        case .started: store.addStr("plan-state", "started")
        case .underway: store.addStr("plan-state", "underway")
        case .finished: store.addStr("plan-state", "finished")
        case .blocked: store.addStr("plan-state", "blocked")
        case .error(let s): store.addStr("plan-state", "error"); store.addStr("plan-state-err", s)
        }
    }
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


