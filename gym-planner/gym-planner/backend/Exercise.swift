/// Types representing a routine within a workout.
import Foundation

public class Exercise: Codable {
    init(_ name: String, _ formalName: String, _ plan: Plan, _ settings: Settings, hidden: Bool = false) {
        self.name = name
        self.formalName = formalName
        self.plan = plan
        self.settings = settings
        self.hidden = hidden
    }
    
    /// This is used for plans that have to run a different plan first, e.g. NRepMaxPlan.
    public func withPlan(_ newName: String, _ newPlan: Plan) -> Exercise {
        return Exercise(newName, formalName, newPlan, settings, hidden: true)
    }
    
    public let name: String             // "Heavy Bench"
    public let formalName: String       // "Bench Press"
    public let plan: Plan
    public let settings: Settings
    
    // If true don't display the plan in UI.
    public let hidden: Bool
}
