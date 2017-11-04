/// Types used to tell the user how to perform an exercise, e.g. how many sets and reps to use for warmup
/// and work sets along with the weight to use for each set. This is done with the aid of a Plan which
/// manages details like progression, deloads, and manipulating volume and intensity across workouts.
import Foundation

/// Used to inform an Instance of the result of an activity.
public struct Completion {
    /// If the activity has more than one Completion then apps will typically use title to populate a popup menu or list view.
    public let title: String
    
    /// Set if the Completion is the one the user is expected to select.
    public let isDefault: Bool
    
    /// Called by apps so that the Instance can move on to whatever the user should do next.
    public let callback: () -> Void
}

/// Generic description of what the user needs to do for a particular activity within an Instance.
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

/// An instance of a Plan, e.g. warmup and work sets for a barbell exercise.
public protocol Instance {
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
}

struct ClassicInstance : Instance {
    func label() -> String {
        return "some label"
    }
    
    func sublabel() -> String {
        return "some sublabel"
    }
    
    func current(n: Int) -> Activity {
        assert(!finished())
        return Activity(title: "dummy", subtitle: "dummier", amount: "10 lbs", details: "25 + 10 lbs", secs: nil)
    }
    
    func restSecs() -> Int {
        return 60
    }
    
    func completions() -> [Completion] {
        return []
    }
    
    func finished() -> Bool {
        return true
    }
    
    func reset() {
        
    }
}

