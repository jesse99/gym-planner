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

        case barbell
        case dumbbell

        case threeDays
        case fourDays
        
        case female
        case ageUnder40
        case age40s
        case age50s
    }
    
    init(_ name: String, _ workouts: [Workout], _ exercises: [Exercise], _ tags: [Tags], _ description: String) {
        self.name = name
        self.workouts = workouts
        self.exercises = exercises
        self.tags = Set(tags)
        self.description = description
        self.customNotes = [:]
    }

    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.workouts = store.getObjArray("workouts")
        self.exercises = store.getObjArray("exercises")
        self.tags = Set(store.getObjArray("tags"))
        self.description = store.getStr("description")
        
        self.customNotes = [:]
        let customNames = store.getStrArray("custom-names", ifMissing: [])
        let customText = store.getStrArray("custom-text", ifMissing: [])
        for (i, name) in customNames.enumerated() {
            customNotes[name] = customText[i]
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addObjArray("workouts", workouts)
        store.addObjArray("exercises", exercises)
        store.addObjArray("tags", Array(tags))
        store.addStr("description", description)
        store.addStrArray("custom-names", Array(customNotes.keys))
        store.addStrArray("custom-text", Array(customNotes.values))
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
        func inProgression(_ name1: String, _ name2: String) -> Bool {
            var name: String? = name1
            while let candidate = name, let exercise = findExercise(candidate) {
                if exercise.name == name2 {
                    return true
                }
                name = exercise.prevExercise
            }

            name = name1
            while let candidate = name, let exercise = findExercise(candidate) {
                if exercise.name == name2 {
                    return true
                }
                name = exercise.nextExercise
            }

            return false
        }
        
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
        
        // TODO: Progression is annoying: maybe we should ask the user to rename (and copy) the program?
        for workout in workouts {
            if let savedWorkout = savedProgram.findWorkout((workout.name)) {
                for (i, exerciseName) in workout.exercises.enumerated() {
                    if !savedWorkout.exercises.contains(exerciseName) {
                        
                        // We've found an exercise in a workout that isn't part of the saved workout.
                        for savedExerciseName in savedWorkout.exercises {
                            // If the saved workout has an exercise not in the builtin workout and that
                            // exercise is part of the progression for the exercise we're missing then
                            // we'll use the saved exercise. Otherwise we'll use the built-in exercise.
                            if !workout.exercises.contains(savedExerciseName) && inProgression(exerciseName, savedExerciseName) {
                                os_log("replacing built-in %@ with %@ for workout %@", type: .info, workout.exercises[i], savedExerciseName, workout.name)
                                workout.exercises[i] = savedExerciseName
                                break
                            }
                        }
                    }
                }
                workout.optional = savedWorkout.optional
            }
        }
        
        customNotes = savedProgram.customNotes
    }
   
    public var name: String             // "Mad Cow"
    public var workouts: [Workout]
    public var exercises: [Exercise]
    public var tags: Set<Tags>
    public var description: String
    public var customNotes: [String: String]    // formal name => markdown
}

/// Helper used when constructing programs.
public func createBarBell(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, useBumpers: Bool = false, magnets: [Double] = [], derivedFrom: String? = nil) -> Exercise {
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets)
    if let otherName = derivedFrom {
        let setting = DerivedWeightSetting(otherName, restSecs: Int(restMins*60.0))
        return Exercise(name, formalName, plan, .derivedWeight(setting))
        
    } else {
        let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
        return Exercise(name, formalName, plan, .variableWeight(setting))
    }
}

public func createMachine(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.machine(range1: defaultMachine(), range2: zeroMachine(), extra: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// Helper used when constructing programs.
public func createFixed(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let setting = FixedWeightSetting(restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func createVarReps(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, requestedReps: Int) -> Exercise {
    let setting = VariableRepsSetting(requestedReps: requestedReps, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableReps(setting))
}

public func createVarSets(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, requestedReps: Int) -> Exercise {
    let setting = VariableRepsSetting(requestedReps: requestedReps, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableReps(setting))
}

public func createCycleReps(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.machine(range1: defaultMachine(), range2: zeroMachine(), extra: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

public func createTimed(_ name: String, _ formalName: String, _ plan: Plan, duration: Int) -> Exercise {
    let setting = FixedWeightSetting(restSecs: duration)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func createCardio(_ name: String, _ plan: Plan) -> Exercise {
    let setting = IntensitySetting()
    return Exercise(name, "", plan, .intensity(setting))
}

public func createHIIT(_ name: String, _ plan: Plan) -> Exercise {
    let setting = HIITSetting(warmupMins: 5, highSecs: 30, lowSecs: 60, cooldownMins: 5, numCycles: 4)
    return Exercise(name, "", plan, .hiit(setting))
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

        case "threeDays": self = .threeDays
        case "fourDays": self = .fourDays
            
        case "barbell": self = .barbell
        case "dumbbell": self = .dumbbell

        case "female": self = .female
        case "ageUnder40": self = .ageUnder40
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

        case .threeDays: store.addStr("tag", "threeDays")
        case .fourDays: store.addStr("tag", "fourDays")
            
        case .barbell: store.addStr("tag", "barbell")
        case .dumbbell: store.addStr("tag", "dumbbell")
            
        case .female: store.addStr("tag", "female")

        case .ageUnder40: store.addStr("tag", "ageUnder40")
        case .age40s: store.addStr("tag", "age40s")
        case .age50s: store.addStr("tag", "age50s")
        }
    }
}
