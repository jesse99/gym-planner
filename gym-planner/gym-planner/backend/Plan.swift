/// Types used to tell the user how to perform an exercise, e.g. how many sets and reps to use for warmup
/// and work sets along with the weight to use for each set. This is done with the aid of a Plan which
/// manages details like progression, deloads, and manipulating volume and intensity across workouts.
import Foundation
import os.log

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
    
    /// "Light Squat". Used on WorkoutController.
    func label() -> String
    
    /// "200 lbs (80% of Heavy Squat)". Used on WorkoutController.
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

    /// Last result is the newest one.
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

fileprivate struct TestFrontEnd: FrontEnd {
    init(_ workout: Workout, _ exercise: Exercise) {
        self.workout = workout
        self.exercise = exercise
    }
    
    public func saveExercise(_ name: String) {
        //os_log("saved %@", type: .debug, name)
    }
    
    public func findWorkout(_ name: String) -> Workout? {
        return name == workout.name ? workout : nil
    }
    
    public func findExercise(_ name: String) -> Exercise? {
        return name == exercise.name ? exercise : nil
    }
    
    public func assert(_ predicate: Bool, _ message: String) {
        if !predicate {
            os_log("ASSERT failed: %@", type: .info, message)
        }
    }
    
    let workout: Workout
    let exercise: Exercise
}

fileprivate func chooseDefaultCompletion(_ completions: [Completion]) {
    if completions.count == 1 {
        os_log("--> %@", type: .info, completions[0].title)
        os_log(" ", type: .info)
        completions[0].callback()
        return
    }
    
    for c in completions {
        if c.isDefault {
            os_log("--> %@", type: .info, c.title)
            os_log(" ", type: .info)
            c.callback()
            return
        }
    }
    frontend.assert(false, "no default completion")
}

fileprivate func chooseAnyCompletion(_ completions: [Completion], _ defaultWeight: Int) {
    if completions.count == 1 {
        os_log("--> %@", type: .info, completions[0].title)
        os_log(" ", type: .info)
        completions[0].callback()
        return
    }
    
    // If there are multiple choices then bias our choice to the default
    var options = Array(completions)
    for c in completions {
        if c.isDefault {
            for _ in 1..<defaultWeight {
                options.append(c)
            }
        }
    }
    
    let index = Int(arc4random_uniform(UInt32(options.count)))
    os_log("--> %@", type: .info, options[index].title)
    os_log(" ", type: .info)
    options[index].callback()
}

fileprivate func runPlan(_ plan: Plan, _ workout: Workout, _ exercise: Exercise, _ numWorkouts: Int, _ choose: ([Completion]) -> ()) {
    func logActivity() {
        let activity = plan.current()
        os_log("%@", type: .info, activity.title)
        if !activity.subtitle.isEmpty {
            os_log("%@", type: .info, activity.subtitle)
        }
        if !activity.amount.isEmpty {
            os_log("%@", type: .info, activity.amount)
        }
        if !activity.details.isEmpty {
            os_log("%@", type: .info, activity.details)
        }
    }
    
    let oldFrontEnd = frontend
    
    frontend = TestFrontEnd(workout, exercise)
    
    let newPlan = plan.start(workout, "default exercise")
    if newPlan == nil {
        os_log("%@ started up", type: .info, plan.typeName)
        
        var count = 1
        os_log("---- %d ---------------------------------", type: .info, count)
        logActivity()
        while count <= numWorkouts {
            switch plan.state {
            case .underway:
                logActivity()
                fallthrough
                
            case .started:
                let completions = plan.completions()
                switch completions {
                case .normal(let cs):
                    choose(cs)
                case .cardio(_):
                    os_log("cardio isn't supported")
                    frontend = oldFrontEnd
                    return
                }
                
            case .finished:
                count += 1
                os_log("---- %d ---------------------------------", type: .info, count)
                _ = plan.start(workout, "default exercise")
                logActivity()
                
            case .waiting:
                os_log("plan state is waiting")
                frontend = oldFrontEnd
                return
                
            case .blocked:
                os_log("plan state is blocked")
                frontend = oldFrontEnd
                return
                
            case .error(let err):
                os_log("plan state is error(%@)", err)
                frontend = oldFrontEnd
                return
            }
        }
        frontend = oldFrontEnd
    } else {
        os_log("%@ started up a new plan", type: .info, plan.typeName)
    }
}

/// This is for testing: it runs the plan the specified number of times using the default
/// completion and logs what happened.
public func runDefaultPlan(_ plan: Plan, _ workout: Workout, _ exercise: Exercise, numWorkouts: Int) {
    runPlan(plan, workout, exercise, numWorkouts, chooseDefaultCompletion)
}

/// This is for testing: it runs the plan the specified number of times using a random
/// completion and logs what happened.
public func runNonDefaultPlan(_ plan: Plan, _ workout: Workout, _ exercise: Exercise, numWorkouts: Int, defaultWeight: Int = 1) {
    let chooser = {(c: [Completion]) -> () in chooseAnyCompletion(c, defaultWeight)}
    runPlan(plan, workout, exercise, numWorkouts, chooser)
}

