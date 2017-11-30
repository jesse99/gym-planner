/// Types encapsulating a set of exercises to perform within workout days.
import Foundation

public class Workout: Storable {
    init(_ name: String, _ exercises: [String], optional: [String] = []) {
        self.name = name
        self.exercises = exercises
        self.optional = optional
    }

    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.exercises = store.getStrArray("exercises")
        self.optional = store.getStrArray("optional")
    }
    
    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addStrArray("exercises", exercises)
        store.addStrArray("optional", optional)
    }

    public var name: String         // "Heavy Day"
    public var exercises: [String]
    public var optional: [String]   // names from exercises that default to inactive
}

public class Program: Storable {
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

    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.workouts = store.getObjArray("workouts")
        self.exercises = store.getObjArray("exercises")
        self.tags = Set(store.getObjArray("tags"))
        self.description = store.getStr("description")
    }
    
    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addObjArray("workouts", workouts)
        store.addObjArray("exercises", exercises)
        store.addObjArray("tags", Array(tags))
        store.addStr("description", description)
    }

    public func findWorkout(_ name: String) -> Workout? {
        return workouts.first {$0.name == name}
    }
    
    public func findExercise(_ name: String) -> Exercise? {
        return exercises.first {$0.name == name}
    }
    
    public func setExercise(_ exercise: Exercise) {
        if let index = exercises.index(where: {$0.name == exercise.name}) {
            exercises[index] = exercise
        } else {
            exercises.append(exercise)
        }
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

extension Program.Tags: Storable {
    public init(from store: Store) {
        let tname = store.getStr("tag")
        switch tname {
        case "beginner": self = .beginner
        case "intermediate": self = .intermediate
        case "advanced": self = .advanced
            
        case "strength": self = .strength
        case "hypertrophy": self = .hypertrophy
        case "conditioning": self = .conditioning
            
        case "female": self = .female
        case "age40s": self = .age40s
        case "age50s": self = .age50s

        default: frontend.assert(false, "loading program had unknown tag: \(tname)"); abort()
        }
    }
    
    public func save(_ store: Store) {
        switch self {
        case .beginner: store.addStr("tag", "beginner")
        case .intermediate: store.addStr("tag", "intermediate")
        case .advanced: store.addStr("tag", "advanced")
            
        case .strength: store.addStr("tag", "strength")
        case .hypertrophy: store.addStr("tag", "hypertrophy")
        case .conditioning: store.addStr("tag", "conditioning")
            
        case .female: store.addStr("tag", "female")
        case .age40s: store.addStr("tag", "age40s")
        case .age50s: store.addStr("tag", "age50s")
        }
    }
}
