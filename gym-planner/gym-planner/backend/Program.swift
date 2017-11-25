/// Types encapsulating a set of exercises to perform within workout days.
import Foundation

public class Workout: Codable {
    init(_ name: String, _ exercises: [String], optional: [String] = []) {
        self.name = name
        self.exercises = exercises
        self.optional = optional
    }
    
    public var name: String         // "Heavy Day"
    public var exercises: [String]
    public var optional: [String]   // names from exercises that default to inactive
}

public class Program: Codable {
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
    
    init(_ name: String, _ workouts: [Workout], _ exercises: [Exercise], _ tags: [Tags], _ description: String) {
        self.name = name
        self.workouts = workouts
        self.exercises = exercises
        self.tags = Set(tags)
        self.description = description
    }
    
    public func findWorkout(_ name: String) -> Workout? {
        return workouts.first {$0.name == name}
    }
    
    public func findExercise(_ name: String) -> Exercise? {
        return exercises.first {$0.name == name}
    }
   
    public var name: String             // "Mad Cow"
    public var workouts: [Workout]
    public var exercises: [Exercise]
    public var tags: Set<Tags>
    public var description: String
    // TODO: may want a custom flag
}

/// Helper used when constructing programs.
public func createBarBell(_ name: String, _ formalName: String, _ plan: Plan, restSecs: Double, warmupsWithBar: Int = 2, useBumpers: Bool = false, magnets: [Double] = [], derived: Bool = false) -> Exercise {
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets, warmupsWithBar: warmupsWithBar)
    if !derived {
        let setting = VariableWeightSetting(apparatus, restSecs: Int(restSecs*60.0))
        return Exercise(name, formalName, plan, .variableWeight(setting))
    } else {
        let setting = DerivedWeightSetting(apparatus, restSecs: Int(restSecs*60.0))
        return Exercise(name, formalName, plan, .derivedWeight(setting))
    }
}

/// Helper used when constructing programs.
public func createFixed(_ name: String, _ formalName: String, _ plan: Plan, restSecs: Double) -> Exercise {
    let setting = FixedWeightSetting(restSecs: Int(restSecs*60.0))
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

