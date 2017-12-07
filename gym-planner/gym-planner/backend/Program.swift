/// Types encapsulating a set of exercises to perform within workout days.
import Foundation
import os.log

public class Workout: Storable {
    init(_ name: String, _ exercises: [String], scheduled: Bool, optional: [String] = []) {
        self.name = name
        self.exercises = exercises
        self.optional = optional
        self.scheduled = scheduled
    }

    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.exercises = store.getStrArray("exercises")
        self.optional = store.getStrArray("optional")
        self.scheduled = store.getBool("scheduled", ifMissing: true)
    }
    
    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addStrArray("exercises", exercises)
        store.addStrArray("optional", optional)
        store.addBool("scheduled", scheduled)
    }

    public var name: String         // "Heavy Day"
    public var exercises: [String]
    
    /// Names from exercises that default to inactive.
    public var optional: [String]
    
    /// True for workouts that are typically performed on a certain day, eg the push day for a
    /// push/pull program. False for stuff like a mobility or cardio workout that can be
    /// performed at any time.
    public var scheduled: Bool
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
    
    /// Used to sync a saved version of a built-in program with the current version
    /// of the built in program. In general all that should be used from the saved
    /// program are settings and plan states (anything else requires a program edit
    /// which requires that the user re-name the program),
    public func sync(_ savedProgram: Program) {
        frontend.assert(name == savedProgram.name, "attempt to sync programs \(name) and \(savedProgram.name)")
        for savedExercise in savedProgram.exercises {
            if let exercise = exercises.first(where: {$0.name == savedExercise.name}) {
                exercise.sync(savedExercise)
            } else if savedExercise.hidden {
                exercises.append(savedExercise)
            } else {
                os_log("dropping saved exercise %@", type: .info, savedExercise.name)
            }
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
public func createBarBell(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, warmupsWithBar: Int = 2, useBumpers: Bool = false, magnets: [Double] = [], derivedFrom: String? = nil) -> Exercise {
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets, warmupsWithBar: warmupsWithBar)
    if let otherName = derivedFrom {
        let setting = DerivedWeightSetting(otherName, restSecs: Int(restMins*60.0))
        return Exercise(name, formalName, plan, .derivedWeight(setting))

    } else {
        let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
        return Exercise(name, formalName, plan, .variableWeight(setting))
    }
}

/// Helper used when constructing programs.
public func createFixed(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let setting = FixedWeightSetting(restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func createReps(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, requestedReps: Int) -> Exercise {
    let setting = VariableRepsSetting(requestedReps: requestedReps, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableReps(setting))
}

public func createTimed(_ name: String, _ formalName: String, _ plan: Plan, duration: Int) -> Exercise {
    let setting = FixedWeightSetting(restSecs: duration)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func makeProgression(_ exercises: [Exercise], _ names: String...) {
    func setNext(_ name: String, _ other: String) {
        let exercise = exercises.first {$0.name == name}!
        exercise.nextExercise = other
    }

    func setPrev(_ name: String, _ other: String) {
        let exercise = exercises.first {$0.name == name}!
        exercise.prevExercise = other
    }
    
    for (i, name) in names.enumerated() {
        if i > 0 {
            setNext(names[i-1], name)
            setPrev(name, names[i-1])
        }
    }
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
