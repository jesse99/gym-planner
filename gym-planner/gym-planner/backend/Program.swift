/// Types encapsulating a set of exercises to perform within workout days.
import Foundation

public class Workout {
    init(_ name: String, _ exercises: [String], optional: [String]) {
        self.name = name
        self.exercises = exercises
        self.optional = optional
    }
    
    public let name: String         // "Heavy Day"
    public let exercises: [String]
    public let optional: [String]   // names from exercises that default to inactive
}

public class Program {
    public enum Tags {
        case beginner
        case intermediate
        case advanced
        
        case strength
        case hypertrophy
        case conditioning
        
        case female
        case age40s
        case age50s
    }
    
    init(_ name: String, _ workouts: [Workout], _ exercises: [Exercise], _ plans: [Plan], _ tags: [Tags], _ description: String) {
        self.name = name
        self.workouts = workouts
        self.exercises = exercises
        self.plans = plans
        self.tags = Set(tags)
        self.description = description
    }
    
    public func findWorkout(_ name: String) -> Workout? {
        return workouts.first {$0.name == name}
    }
    
    public func findExercise(_ name: String) -> Exercise? {
        return exercises.first {$0.name == name}
    }
    
    public func findPlan(_ name: String) -> Plan? {
        return plans.first {$0.name == name}
    }
    
    public let name: String             // "Mad Cow"
    public let workouts: [Workout]
    public let exercises: [Exercise]
    public let plans: [Plan]
    public let tags: Set<Tags>
    public let description: String
    // TODO: may want a custom flag
}

