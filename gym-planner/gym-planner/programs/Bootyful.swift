import Foundation

fileprivate func planVarying(_ numSets: Int, _ minReps: Int, _ maxReps: Int) -> Plan {
    return VariableRepsPlan("\(numSets)x\(minReps)-\(maxReps)", numSets: numSets, minReps: minReps, maxReps: maxReps)
}

fileprivate func planFixed(_ numSets: Int, _ numReps: Int) -> Plan {
    return FixedSetsPlan("\(numSets)x\(numReps)", numSets: numSets, numReps: numReps)
}

fileprivate func planTimed(_ numSets: Int, targetTime: Int? = nil) -> Plan {
    return TimedPlan("\(numSets) timed sets", numSets: numSets, targetTime: targetTime)
}

fileprivate func planWeighted8to12() -> Plan {
    let numSets = 3
    let minReps = 8
    let maxReps = 12
    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
}

fileprivate func planWeighted5to10() -> Plan {
    let numSets = 1
    let minReps = 5     // this called for 1x10 which seems silly
    let maxReps = 10
    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
}

fileprivate func planWeighted10to20() -> Plan {
    let numSets = 3
    let minReps = 10
    let maxReps = 20
    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
}

fileprivate let booty14Exercises = [
    // A
    createVarReps("Glute Bridge",                 "Glute Bridge",               planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createDumbbell2("One Arm Row",                "Kroc Row",                   planWeighted8to12(), restMins: 0.5),
    createVarReps("Box Squat",                    "Body-weight Box Squat",      planVarying(3, 10, 20), restMins: 1.0, requestedReps: 10),
    createDumbbell2("Dumbbell Bench Press",       "Dumbbell Bench Press",       planWeighted8to12(), restMins: 1.0),
    createDumbbell2("Dumbbell Romanian Deadlift", "Dumbbell Romanian Deadlift", planWeighted10to20(), restMins: 1.0),
    createVarReps("Side Lying Abduction",         "Side Lying Abduction",       planVarying(2, 15, 30), restMins: 0.5, requestedReps: 15),
    createTimed("Front Plank",                    "Front Plank",                planTimed(1, targetTime: 120), duration: 20),
    createTimed("Side Plank from Knees",          "Side Plank",                 planTimed(2, targetTime: 60), duration: 20),
    
    // B
    // Glute Bridge
    createMachine("Lat Pulldown",  "Lat Pulldown",                     planWeighted8to12(), restMins: 1.0),
    createVarReps("Step-up",         "Step-ups",                       planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createDumbbell2("Dumbbell OHP",  "Dumbbell Seated Shoulder Press", planWeighted8to12(), restMins: 1.0),
    createVarReps("Back Extension",  "Step-ups",                       planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createVarReps("Side Lying Clam", "Clam",                           planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Crunch",          "Situp",                          planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Side Crunch",     "Oblique Crunches",               planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    
    // C
    createTimed("Glute March",                "Glute March",                     planTimed(3, targetTime: 60), duration: 60),
    createMachine("Seated Row",               "Seated Cable Row",                planWeighted8to12(), restMins: 1.0),
    // Box Squat
    createDumbbell2("Dumbbell Incline Press", "Dumbbell Incline Press",          planWeighted8to12(), restMins: 1.0),
    createVarReps("Romanian Deadlift",        "Body-weight Single Leg Deadlift", planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createVarReps("X-Band Walk",              "X-Band Walk",                     planVarying(1, 10, 20), restMins: 0.5, requestedReps: 10),
    createTimed("RKC Plank",                  "RKC Plank",                       planTimed(1, targetTime: 30), duration: 10),
    createMachine("Rope Horizontal Chop",     "Rope Horizontal Chop",            planWeighted5to10(), restMins: 0.5),
    
    // AC Warmup
    createFixed("Foam Rolling",                 "IT-Band Foam Roll",               planFixed(1, 10), restMins: 0.0),
    createTimed("Hamstring Stretch",            "Foot Elevated Hamstring Stretch", planTimed(2, targetTime: 30), duration: 30),
    createTimed("Psoas Stretch",                "Forward Lunge Stretch",           planTimed(2, targetTime: 30), duration: 30),
    createTimed("Adductors",                    "Standing Wide Leg Straddle",      planTimed(1, targetTime: 30), duration: 30),
    createTimed("Side Lying Abduction",         "Side Lying Abduction",            planTimed(2, targetTime: 30), duration: 30),
    createFixed("Bird-dog",                     "Bird-dog",                        planFixed(1, 8), restMins: 0.0),
    createTimed("Front Plank",                  "Front Plank",                     planTimed(1, targetTime: 120), duration: 20),
    createFixed("LYTP",                         "LYTP",                            planFixed(1, 10), restMins: 0.0),
    createFixed("Walking Lunge",                "Body-weight Walking Lunge",       planFixed(1, 10), restMins: 0.0),
    createFixed("Wall Ankle Mobility",          "Wall Ankle Mobility",             planFixed(1, 10), restMins: 0.0),
    createFixed("Quadruped Thoracic Extension", "Quadruped Thoracic Extension",    planFixed(1, 10), restMins: 0.0),
    createFixed("Rotational Lunge",             "Rotational Lunge",                planFixed(1, 10), restMins: 0.0),
    
    // B Warmup
    createFixed("Tiger Tail Roller",             "Tiger Tail Roller",                planFixed(1, 10), restMins: 0.0),
    createFixed("SMR Glutes with Ball",          "SMR Glutes with Ball",             planFixed(1, 10), restMins: 0.0),
    createTimed("Standing Quad Stretch",         "Standing Quad Stretch",            planTimed(2, targetTime: 30), duration: 30),
    createTimed("Seated Piriformis Stretch",     "Seated Piriformis Stretch",        planTimed(2, targetTime: 30), duration: 30),
    createTimed("One-Handed Hang",               "One-Handed Hang",                  planTimed(2, targetTime: 30), duration: 20),
    createTimed("Pec Stretch",                   "Doorway Chest Stretch",            planTimed(2, targetTime: 30), duration: 30),
    createTimed("Clam",                          "Clam",                             planTimed(2, targetTime: 30), duration: 30),
    createTimed("Side Plank",                    "Side Plank",                       planTimed(2, targetTime: 60), duration: 20),
    createFixed("Pushup Plus",                   "Pushup Plus",                      planFixed(1, 10), restMins: 0.0),
    createFixed("Wall Extensions",               "Wall Extensions",                  planFixed(1, 10), restMins: 0.0),
    createFixed("Walking Knee Hugs",             "Walking Knee Hugs",                planFixed(1, 10), restMins: 0.0),
    // omitted Superman per https://www.duncansportspt.com/2015/07/superman-exercise/
    createFixed("Squat to Stand",                "Squat to Stand",                   planFixed(1, 10), restMins: 0.0),
    createFixed("Swiss Ball Internal Rotation",  "Swiss Ball Hip Internal Rotation", planFixed(1, 10), restMins: 0.0),
]

fileprivate let booty14AExercises = ["Glute Bridge", "One Arm Row", "Box Squat", "Dumbbell Bench Press", "Dumbbell Romanian Deadlift", "Side Lying Abduction", "Front Plank", "Front Plank", "Side Plank from Knees"]
fileprivate let booty14BExercises = ["Glute Bridge", "Lat Pulldown", "Step-up", "Dumbbell OHP", "Back Extension", "Side Lying Clam", "Crunch", "Side Crunch"]
fileprivate let booty14CExercises = ["Glute March", "Seated Row", "Box Squat", "Dumbbell Incline Press", "Romanian Deadlift", "X-Band Walk", "RKC Plank", "Rope Horizontal Chop"]

fileprivate let booty14ACWarmup = ["Foam Rolling", "Hamstring Stretch", "Psoas Stretch", "Adductors", "Side Lying Abduction", "Bird-dog", "Front Plank", "LYTP", "Walking Lunge", "Wall Ankle Mobility", "Quadruped Thoracic Extension", "Rotational Lunge"]
fileprivate let booty14BWarmup = ["Tiger Tail Roller", "SMR Glutes with Ball", "Standing Quad Stretch", "Seated Piriformis Stretch", "One-Handed Hang", "Pec Stretch", "Clam", "Side Plank", "Pushup Plus", "Wall Extensions", "Walking Knee Hugs", "Squat to Stand", "Swiss Ball Internal Rotation"]

fileprivate let booty14ADesc = """
* Bodyweight Glute Bridge 3x10-20
* One Arm Row 3x8-12 (each side)
* Bodyweight Box Squat 3x10-20
* Dumbbell Bench Press 3x8-12
* Dumbbell Romanian Deadlift 3x10-20
* Side Lying Abduction 2x15-30 (set per side)
* Front Plank 1x20-120s
* Side Plank from Knees 1x20-60s (set per side)
"""

fileprivate let booty14BDesc = """
* Bodyweight Single-leg Glute Bridge 3x10-20 (set per side)
* Lat Pulldown 3x8-12
* Bodyweight Step-up 3x10-20 (set per side)
* Dumbbell Overhead Press 3x8-12
* Back Extension 3x10-20
* Side Lying Clam 1x15-30 (set per side)
* Crunch 1x15-30
* Side Crunch 1x15-30 (set per side)
"""

fileprivate let booty14CDesc = """
* Glute March 3x60s
* Seated Row 3x8-12
* Bodyweight Squat 3x10-20
* Dumbbell Incline Press 3x8-12
* Bodyweight Romanian Deadlift 3x10-20 (set per side)
* X-Band Walk (light tension) 1x10-20 steps (set pet side)
* RKC Plank 1x10-30s
* Rope Horz Chop 1x5-10 (set pet side)
"""

fileprivate let booty14Notes = """
* Bret recommends spending 10-15 minutes warming up before each workout.
* When foam rolling Bret recommends hitting the erectors, quads, IT Band, hip flexors, hamsttrings, adductors, glutes, calves, and lats.
* For the Stick/Tiger Tail roller warmup hit the IT-band, quads, calves, and shins.
* Focus on activating the glutes with each exercise.
* When performing a single leg/arm exercise begin with the weaker limb and then do the same number of reps with the stronger limb.
* If you're having an off day don't continue a set if your form begins to break down.
* To speed up the workouts you can superset the exercises: do a set of a lower body exercise, a set of an upper body, rest for 60-120s, and repeat until you've finished all the sets for both exercises.
* Once you've done all the indicated workouts the app will prompt you to move onto the next program.
"""

// Weeks 1-4 for 4 days/week version of Booty-ful Beginnings.
func Bootyful4a() -> Program {
    let workouts = [
        Workout("A1", booty14AExercises, scheduled: true, optional: []),
        Workout("B",  booty14BExercises, scheduled: true, optional: []),
        Workout("A2", booty14AExercises, scheduled: true, optional: []),
        Workout("C",  booty14CExercises, scheduled: true, optional: []),

        Workout("AC warmup", booty14ACWarmup, scheduled: false, optional: []),
        Workout("B warmup", booty14BWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.beginner, .strength, .gym, .fourDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
This is the 4 days/week version of weeks 1-4 of the beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):

**Workout A**
\(booty14ADesc)

**Workout B**
\(booty14BDesc)

**Cardio**

**Workout A (again)**

**Workout C**
\(booty14CDesc)

**Cardio**

**Rest**

**Notes**
\(booty14Notes)
"""
    return Program("Booty-ful Beginnings/4 1-4", workouts, booty14Exercises, tags, description, maxWorkouts: 4*4, nextProgram: "Booty-ful Beginnings/4 5-8")
}

// Weeks 1-4 for 3 days/week version of Booty-ful Beginnings.
func Bootyful3a() -> Program {
    let workouts = [
        Workout("A", booty14AExercises, scheduled: true, optional: []),
        Workout("B", booty14BExercises, scheduled: true, optional: []),
        Workout("C", booty14CExercises, scheduled: true, optional: []),
        
        Workout("AC warmup", booty14ACWarmup, scheduled: false, optional: []),
        Workout("B warmup", booty14BWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.beginner, .strength, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is the 3 days/week version of weeks 1-4 of the beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):
    
    **Workout A**
    \(booty14ADesc)
    
    **Cardio**
    
    **Workout B**
    \(booty14BDesc)
    
    **Cardio**
    
    **Workout C**
    \(booty14CDesc)
    
    **Cardio**
    
    **Rest**
    
    **Notes**
    \(booty14Notes)
    """
    return Program("Booty-ful Beginnings/3 1-4", workouts, booty14Exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Booty-ful Beginnings/3 5-8")
}

