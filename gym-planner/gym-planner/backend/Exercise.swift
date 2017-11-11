/// Types representing a routine within a workout.
import Foundation

public class Exercise {
    init(_ name: String, _ formalName: String, _ settings: Settings) {
        self.name = name
        self.formalName = formalName
        self.settings = settings
    }
    
    public let name: String             // "Heavy Bench"
    public let formalName: String       // "Bench Press"
    public let settings: Settings
}
