/// Types encapsulating a set of exercises to perform within workout days.
import Foundation
import os.log

public class Workout: Storable {
    init(_ name: String, _ exercises: [String], scheduled: Bool = true, optional: [String] = []) {
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

    public func errors(_ program: Program) -> [String] {
        var problems: [String] = []
        
        for n in Set(exercises) {
            if exercises.count({$0 == n}) > 1 {
                problems += ["workout \(name) exercise (\(n)) appears more than once"]
            }
        }
        
        for n in Set(optional) {
            if optional.count({$0 == n}) > 1 {
                problems += ["workout \(name) optional (\(n)) appears more than once"]
            }
        }
        
        for n in Set(optional) {
            if !exercises.contains(n) {
                problems += ["workout \(name) optional (\(n)) isn't in exercises"]
            }
        }
        
        for n in Set(exercises) {
            if program.findExercise(n) == nil {
                problems += ["workout \(name) exercises (\(n)) isn't in the program"]
            }
        }
        
        return problems
    }
}

public class Program: Storable {
    public enum Tags {
        case beginner       // weight is expected to increase each workout
        case intermediate   // weight increases each week
        case advanced       // weight takes longer than a week to increase
        
        case strength
        case hypertrophy
        case conditioning

        case gym
        case barbell
        case dumbbell
        case minimal

        case threeDays
        case fourDays
        case fiveDays
        case sixDays
        
        case unisex
        case female
        
        case ageUnder40
        case age40s
        case age50s
    }
    
    init(_ name: String, _ workouts: [Workout], _ exercises: [Exercise], _ tags: [Tags], _ description: String, maxWorkouts: Int?, nextProgram: String?) {
        self.name = name
        self.workouts = workouts
        self.exercises = exercises
        self.tags = Set(tags)
        self.description = description
        self.customNotes = [:]
        self.maxWorkouts = maxWorkouts
        self.nextProgram = nextProgram
    }

    convenience init(_ name: String, _ workouts: [Workout], _ exercises: [Exercise], _ tags: [Tags], _ description: String) {
        self.init(name, workouts, exercises, tags, description, maxWorkouts: nil, nextProgram: nil)
    }

    public func errors() -> [String] {
        var problems: [String] = []
        
        for w in workouts {
            problems += w.errors(self)
        }
        
        for e in exercises {
            problems += e.errors(self)

            if builtInNotes[e.formalName] == nil && customNotes[e.formalName] == nil {
                problems += ["exercise \(e.name) formalName (\(e.formalName)) is missing from notes"]
            }
        }
        
        if let n = maxWorkouts {
            if n < 0 {
                problems += ["program.maxWorkouts is less than 0"]
            } else if n == 0 && nextProgram != nil {
                problems += ["program.nextProgram is set but maxWorkouts is 0"]
            } else if n > 0 && nextProgram == nil {
                problems += ["program.maxWorkouts is set but nextProgram isn't"]
            }
        } else {
            if nextProgram != nil {
                problems += ["program.nextProgram is set but maxWorkouts isn't"]
            }
        }
        
        if tags.contains(.beginner) && tags.contains(.intermediate) {
            problems += ["program.tags has both beginner and intermediate"]
        }
        if tags.contains(.beginner) && tags.contains(.advanced) {
            problems += ["program.tags has both beginner and advanced"]
        }
        if tags.contains(.intermediate) && tags.contains(.advanced) {
            problems += ["program.tags has both intermediate and advanced"]
        }
        
        if tags.contains(.strength) && tags.contains(.hypertrophy) {
            problems += ["program.tags has both strength and hypertrophy"]
        }
        if tags.contains(.hypertrophy) && tags.contains(.conditioning) {
            problems += ["program.tags has both hypertrophy and conditioning"]
        }

        if tags.contains(.gym) && tags.contains(.barbell) {
            problems += ["program.tags has both gym and barbell"]
        }
        if tags.contains(.gym) && tags.contains(.dumbbell) {
            problems += ["program.tags has both gym and dumbbell"]
        }
        if tags.contains(.gym) && tags.contains(.minimal) {
            problems += ["program.tags has both gym and minimal"]
        }

        if tags.contains(.barbell) && tags.contains(.dumbbell) {
            problems += ["program.tags has both barbell and dumbbell"]
        }
        if tags.contains(.barbell) && tags.contains(.minimal) {
            problems += ["program.tags has both barbell and minimal"]
        }

        if tags.contains(.dumbbell) && tags.contains(.minimal) {
            problems += ["program.tags has both dumbbell and minimal"]
        }
        
        // check for threeDays
        if tags.contains(.threeDays) && tags.contains(.fourDays) {
            problems += ["program.tags has both threeDays and fourDays"]
        }
        
        if tags.contains(.threeDays) && tags.contains(.fiveDays) {
            problems += ["program.tags has both threeDays and fiveDays"]
        }

        if tags.contains(.threeDays) && tags.contains(.sixDays) {
            problems += ["program.tags has both threeDays and sixDays"]
        }

        // check for fourDays
        if tags.contains(.fourDays) && tags.contains(.fiveDays) {
            problems += ["program.tags has both fourDays and fiveDays"]
        }

        if tags.contains(.fourDays) && tags.contains(.sixDays) {
            problems += ["program.tags has both fourDays and sixDays"]
        }

        // check for fiveDays
        if tags.contains(.fiveDays) && tags.contains(.sixDays) {
            problems += ["program.tags has both fiveDays and sixDays"]
        }

        if tags.contains(.unisex) && tags.contains(.female) {
            problems += ["program.tags has both unisex and female"]
        }

        return problems
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
    
    public var maxWorkouts: Int?    // number of workouts that the user is expected to perform before switching to a new program
    public var nextProgram: String? // if the program has a well defined successor than it should be listed here
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
        case "fiveDays": self = .fiveDays
        case "sixDays": self = .sixDays
            
        case "gym": self = .gym
        case "barbell": self = .barbell
        case "dumbbell": self = .dumbbell
        case "minimal": self = .minimal

        case "unisex": self = .unisex
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
        case .fiveDays: store.addStr("tag", "fiveDays")
        case .sixDays: store.addStr("tag", "sixDays")
            
        case .gym: store.addStr("tag", "gym")
        case .barbell: store.addStr("tag", "barbell")
        case .dumbbell: store.addStr("tag", "dumbbell")
        case .minimal: store.addStr("tag", "minimal")

        case .unisex: store.addStr("tag", "unisex")
        case .female: store.addStr("tag", "female")

        case .ageUnder40: store.addStr("tag", "ageUnder40")
        case .age40s: store.addStr("tag", "age40s")
        case .age50s: store.addStr("tag", "age50s")
        }
    }
}
