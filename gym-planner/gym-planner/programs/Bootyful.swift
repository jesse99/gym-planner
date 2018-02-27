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

fileprivate func planWeighted3to10() -> Plan {
    let numSets = 3
    let minReps = 3
    let maxReps = 10
    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
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

fileprivate func planWeighted10to15() -> Plan {
    let numSets = 3
    let minReps = 10
    let maxReps = 15
    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
}

fileprivate func planWeighted15to30() -> Plan {
    let numSets = 3
    let minReps = 14
    let maxReps = 30
    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
}

let strongCurvesWarmups = [
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
    createMachine("Lat Pulldown",    "Lat Pulldown",             planWeighted8to12(), restMins: 1.0),
    createVarReps("Step-up",         "Step-ups",                 planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createDumbbell2("Dumbbell OHP",  "Dumbbell Shoulder Press",  planWeighted8to12(), restMins: 1.0),
    createVarReps("Back Extension",  "Back Extension",           planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createVarReps("Side Lying Clam", "Clam",                     planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Crunch",          "Situp",                    planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Side Crunch",     "Oblique Crunches",         planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    
    // C
    createTimed("Glute March",                "Glute March",                     planTimed(3, targetTime: 60), duration: 60),
    createMachine("Seated Row",               "Seated Cable Row",                planWeighted8to12(), restMins: 1.0),
    // Box Squat
    createDumbbell2("Dumbbell Incline Press", "Dumbbell Incline Press",          planWeighted8to12(), restMins: 1.0),
    createVarReps("Romanian Deadlift",        "Body-weight Single Leg Deadlift", planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createVarReps("X-Band Walk",              "X-Band Walk",                     planVarying(1, 10, 20), restMins: 0.5, requestedReps: 10),
    createTimed("RKC Plank",                  "RKC Plank",                       planTimed(1, targetTime: 30), duration: 10),
    createMachine("Rope Horizontal Chop",     "Rope Horizontal Chop",            planWeighted5to10(), restMins: 0.5),
    ] + strongCurvesWarmups

fileprivate let booty58Exercises = [
    // A
    createVarReps("Hip Thrust",              "Body-weight Hip Thrust",               planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createMachine("One Arm Cable Row",       "Standing One Arm Cable Row",           planWeighted8to12(), restMins: 0.5),
    createVarReps("Step Up + Reverse Lunge", "Body-weight Step Up + Reverse Lunge",  planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createBarBell("Bench Press",             "Bench Press",                          planWeighted8to12(), restMins: 2.0),
    createBarBell("Romanian Deadlift",       "Romanian Deadlift",                    planWeighted10to20(), restMins: 2.0),
    createVarReps("Side Lying Abduction",    "Side Lying Abduction",                 planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createTimed("Decline Plank",             "Decline Plank",                        planTimed(1, targetTime: 60), duration: 20),
    createTimed("Side Plank",                "Side Plank",                           planTimed(2, targetTime: 60), duration: 20),
    
    // B
    createVarReps("Glute Bridge",           "Glute Bridge",              planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createFixed("Negative Chinup",        "Chinup",                      planFixed(3, 3), restMins: 1.0),
    createVarReps("Walking Lunge",          "Body-weight Walking Lunge", planVarying(3, 10, 20), restMins: 1.0, requestedReps: 10),
    createDumbbell2("Dumbbell OHP",         "Dumbbell Shoulder Press",   planWeighted8to12(), restMins: 1.0),
    createVarReps("Reverse Hyperextension", "Reverse Hyperextension",    planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createVarReps("Clam",                   "Clam",                      planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Swiss Ball Crunch",      "Exercise Ball Crunch",      planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Swiss Ball Side Crunch", "Exercise Ball Side Crunch", planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    
    // C
    createVarReps("Hip Thrust (paused)",    "Body-weight Hip Thrust",   planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createVarReps("Inverted Row",           "Inverted Row",             planVarying(3, 8, 12), restMins: 0.5, requestedReps: 8),
    createDumbbell2("Goblet Squat",         "Goblet Squat",             planWeighted10to20(), restMins: 2.0),
    createBarBell("Close-Grip Bench Press", "Close-Grip Bench Press",   planWeighted8to12(), restMins: 2.0),
    createVarReps("Kettlebell Swing",       "Kettlebell Two Arm Swing", planVarying(3, 10, 20), restMins: 0.5, requestedReps: 10),
    createVarReps("X-Band Walk",            "X-Band Walk",              planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Straight Leg Situp",     "Straight Leg Situp",       planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createTimed("Anti-Rotary Hold",         "Band Anti-Rotary Hold",    planTimed(2, targetTime: 20), duration: 10),
    ] + strongCurvesWarmups

fileprivate let booty912Exercises = [
    // A
    createBarBell("Hip Thrust",           "Hip Thrust",             planWeighted10to20(), restMins: 1.0),
    createDumbbell2("Dumbbell Row",       "Bent Over Dumbbell Row", planWeighted8to12(), restMins: 1.0),
    createBarBell("Box Squat",            "Box Squat",              planWeighted10to20(), restMins: 2.0),
    createVarReps("Pushup",               "Pushup",                 planVarying(3, 3, 10), restMins: 0.5, requestedReps: 3),
    createBarBell("Deadlift",             "Deadlift",               planWeighted10to20(), restMins: 2.0),
    createVarReps("Side Lying Abduction", "Side Lying Abduction",   planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Dumbbell Ball Crunch", "Exercise Ball Crunch",   planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createMachine("Anti-Rotation Press",  "Half-kneeling Cable Anti-Rotation Press", planWeighted10to15(), restMins: 0.5),

    // B
    createFixed("Single Leg Hip Thrust",   "Body-weight Single Leg Hip Thrust",   planFixed(3, 20), restMins: 1.0),
    createVarReps("Chinup",                "Chinup",                            planVarying(3, 1, 5), restMins: 1.0, requestedReps: 1),
    createVarReps("Bulgarian Split Squat", "Body-weight Bulgarian Split Squat", planVarying(3, 10, 20), restMins: 1.0, requestedReps: 10),
    createDumbbell2("One Arm OHP",         "Dumbbell One Arm Shoulder Press",   planWeighted8to12(), restMins: 1.0),
    createBarBell("Good Morning",          "Good Morning",                      planWeighted10to20(), restMins: 1.0),
    createVarReps("X-Band Walk",           "X-Band Walk",                       planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createTimed("Decline Plank",           "Decline Plank",                     planTimed(1, targetTime: 120), duration: 60),
    createDumbbell2("Side Bend",           "Dumbbell Side Bend",                planWeighted15to30(), restMins: 1.0),

    // C
    createBarBell("Hip Thrust (paused)",   "Hip Thrust",             planWeighted8to12(), restMins: 1.0),
    createDumbbell2("Incline Row",         "Dumbbell Incline Row",   planWeighted8to12(), restMins: 1.0),
    createBarBell("Squat",                 "Low bar Squat",          planWeighted10to20(), restMins: 2.0),
    createBarBell("Incline Bench Press",   "Incline Bench Press",    planWeighted3to10(), restMins: 2.0),
    createVarReps("Back Extension",        "Back Extension",         planVarying(3, 10, 30), restMins: 0.5, requestedReps: 10),
    createVarReps("Clam",                  "Clam",                   planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
    createVarReps("Hanging Leg Raise",     "Hanging Leg Raise",      planVarying(1, 10, 20), restMins: 0.5, requestedReps: 10),
    createMachine("Rope Horizontal Chop",  "Rope Horizontal Chop",   planWeighted10to15(), restMins: 0.5),
] + strongCurvesWarmups

fileprivate let booty14AExercises = ["Glute Bridge", "One Arm Row", "Box Squat", "Dumbbell Bench Press", "Dumbbell Romanian Deadlift", "Side Lying Abduction", "Front Plank", "Front Plank", "Side Plank from Knees"]
fileprivate let booty14BExercises = ["Glute Bridge", "Lat Pulldown", "Step-up", "Dumbbell OHP", "Back Extension", "Side Lying Clam", "Crunch", "Side Crunch"]
fileprivate let booty14CExercises = ["Glute March", "Seated Row", "Box Squat", "Dumbbell Incline Press", "Romanian Deadlift", "X-Band Walk", "RKC Plank", "Rope Horizontal Chop"]

fileprivate let booty58AExercises = ["Hip Thrust", "One Arm Cable Row", "Step Up + Reverse Lunge", "Bench Press", "Romanian Deadlift", "Side Lying Abduction", "Decline Plank", "Side Plank"]
fileprivate let booty58BExercises = ["Glute Bridge", "Negative Chinup", "Walking Lunge", "Dumbbell OHP", "Reverse Hyperextension", "Clam", "Swiss Ball Crunch", "Swiss Ball Side Crunch"]
fileprivate let booty58CExercises = ["Hip Thrust (paused)", "Inverted Row", "Goblet Squat", "Close-Grip Bench Press", "Kettlebell Swing", "X-Band Walk", "Straight Leg Situp", "Anti-Rotary Hold"]

fileprivate let booty912AExercises = ["Hip Thrust", "Dumbbell Row", "Box Squat", "Pushup", "Deadlift", "Side Lying Abduction", "Dumbbell Ball Crunch", "Anti-Rotation Press"]
fileprivate let booty912BExercises = ["Single Leg Hip Thrust", "Chinup", "Bulgarian Split Squat", "One Arm OHP", "Good Morning", "X-Band Walk", "Decline Plank", "Side Bend"]
fileprivate let booty912CExercises = ["Hip Thrust (paused)", "Incline Row", "Squat", "Incline Bench Press", "Back Extension", "Clam", "Hanging Leg Raise", "Rope Horizontal Chop"]

let strongCurvesACWarmup = ["Foam Rolling", "Hamstring Stretch", "Psoas Stretch", "Adductors", "Side Lying Abduction", "Bird-dog", "Front Plank", "LYTP", "Walking Lunge", "Wall Ankle Mobility", "Quadruped Thoracic Extension", "Rotational Lunge"]
let strongCurvesBWarmup = ["Tiger Tail Roller", "SMR Glutes with Ball", "Standing Quad Stretch", "Seated Piriformis Stretch", "One-Handed Hang", "Pec Stretch", "Clam", "Side Plank", "Pushup Plus", "Wall Extensions", "Walking Knee Hugs", "Squat to Stand", "Swiss Ball Internal Rotation"]

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
* X-Band Walk (light tension) 1x10-20 steps (set per side)
* RKC Plank 1x10-30s
* Rope Horz Chop 1x5-10 (set per side)
"""

fileprivate let booty58ADesc = """
Bodyweight Hip Thrust 3x10-20
Standing Single-arm Cable-row 3x8-12
Bodyweight Step up/Reverse lunge 3x10-20
Bench Press 3x8-12
Romanian Deadlift 3x10-20
Side Lying Abduction 1x15-30
Feet Elevated Plank 1x20-60s
Side Plank 1x20-60s
"""

fileprivate let booty58BDesc = """
Bodyweight Single-leg Glute Bridge 3x-10-20 (set per side)
Negative Chinup 3x3 (or lat pulldown)
Bodyweight Walking Lunge 3x10-20
Dumbbell OHP 3x8-12
Bodyweight Reverse Hyper 3x10-20
Side Lying Clam 1x15-30 (per side)
Swiss Ball Crunch 1x15-30
Swiss Ball Side Crunch 1x15-30
"""

fileprivate let booty58CDesc = """
Bodyweight Hip thrust 3x10-20 (paused)
Modified Inverted Row 3x8-12
Goblet squat 3x10-20
Close-grip Bench Press 3x8-12
Russuian Kettlebell Swing 3x10-20
X-band Walk (moderate) 1x15-30 (set per side)
Straight-leg Situp 1x15-30
Band Rotary Hold 1x10-20s (set per side)
"""

fileprivate let booty912ADesc = """
Barbell Hip Thrust 3x10-20
Dumbbell Bent Over Row 3x8-12
Barbell Box Squat 3x10-20
Push-up 3x-3-10
Barbell Deadlift 3x10-20
Side Lying Abduction 1x15-30 (set pet side)
Dumbbell Swiss Ball Crunch 1x-15-30 (set pet side)
Half-kneeling Cable Anti-Rotation Press 1x10-15 (set per side)
"""

fileprivate let booty912BDesc = """
Bodyweight Single-leg Hip Thrust (shoulders elevated) 3x10-20 (set per side)
Chin-up (or assisted) 3x1-5
Bodyweight Bulgarian Split Squat 3x10-20
Single-arm Dumbbell OHP 3x8-12
Barbell Good Morning 3x10-20
X-band Walk (moderate) 1x15-30 (set per side)
Feet Elevated Plank 1x60-120s
Dumbbell Side Bend 1x15-30 (set per side)
"""

fileprivate let booty912CDesc = """
Barbell Hip Thrust (paused) 3x8-12
Dumbbell Chest Supported Row 3x8-10
Barbell Squat 3x10-20
Incline Press 3x3-10
Bodyweight Back Extension 3x10-30
Side Lying Clam 1x15-30 (set pet side)
Hanging Leg Raise 1x10-20
Rope Horizontal Chop 1x10-15 (set per side)
"""

fileprivate let bootyNotes = """
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
        
        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .fourDays, .female, .ageUnder40, .age40s, .age50s]
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
    \(bootyNotes)
    """
    return Program("Booty-ful Beginnings/4 1-4", workouts, booty14Exercises, tags, description, maxWorkouts: 4*4, nextProgram: "Booty-ful Beginnings/4 5-8")
}

// Weeks 5-8 for 4 days/week version of Booty-ful Beginnings.
func Bootyful4b() -> Program {
    let workouts = [
        Workout("A1", booty58AExercises, scheduled: true, optional: []),
        Workout("B",  booty58BExercises, scheduled: true, optional: []),
        Workout("A2", booty58AExercises, scheduled: true, optional: []),
        Workout("C",  booty58CExercises, scheduled: true, optional: []),
        
        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .fourDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is the 4 days/week version of weeks 5-8 of the beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):
    
    **Workout A**
    \(booty58ADesc)
    
    **Workout B**
    \(booty58BDesc)
    
    **Cardio**
    
    **Workout A (again)**
    
    **Workout C**
    \(booty58CDesc)
    
    **Cardio**
    
    **Rest**
    
    **Notes**
    \(bootyNotes)
    """
    return Program("Booty-ful Beginnings/4 5-8", workouts, booty58Exercises, tags, description, maxWorkouts: 4*4, nextProgram: "Booty-ful Beginnings/4 9-12")
}

// Weeks 9-12 for 4 days/week version of Booty-ful Beginnings.
func Bootyful4c() -> Program {
    let workouts = [
        Workout("A1", booty912AExercises, scheduled: true, optional: []),
        Workout("B",  booty912BExercises, scheduled: true, optional: []),
        Workout("A2", booty912AExercises, scheduled: true, optional: []),
        Workout("C",  booty912CExercises, scheduled: true, optional: []),

        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .fourDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
This is the 4 days/week version of weeks 9-12 of the beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):

**Workout A**
\(booty912ADesc)

**Workout B**
\(booty912BDesc)

**Cardio**

**Workout A (again)**

**Workout C**
\(booty912CDesc)

**Cardio**

**Rest**

**Notes**
\(bootyNotes)
"""
    return Program("Booty-ful Beginnings/4 9-12", workouts, booty912Exercises, tags, description, maxWorkouts: 4*4, nextProgram: "Gluteal Goddess/4 1-4")
}

// Weeks 1-4 for 3 days/week version of Booty-ful Beginnings.
func Bootyful3a() -> Program {
    let workouts = [
        Workout("A", booty14AExercises, scheduled: true, optional: []),
        Workout("B", booty14BExercises, scheduled: true, optional: []),
        Workout("C", booty14CExercises, scheduled: true, optional: []),
        
        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
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
    \(bootyNotes)
    """
    return Program("Booty-ful Beginnings/3 1-4", workouts, booty14Exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Booty-ful Beginnings/3 5-8")
}

// Weeks 5-8 for 3 days/week version of Booty-ful Beginnings.
func Bootyful3b() -> Program {
    let workouts = [
        Workout("A", booty58AExercises, scheduled: true, optional: []),
        Workout("B", booty58BExercises, scheduled: true, optional: []),
        Workout("C", booty58CExercises, scheduled: true, optional: []),
        
        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is the 3 days/week version of weeks 5-8 of the beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):
    
    **Workout A**
    \(booty58ADesc)
    
    **Cardio**
    
    **Workout B**
    \(booty58BDesc)
    
    **Cardio**
    
    **Workout C**
    \(booty58CDesc)
    
    **Cardio**
    
    **Rest**
    
    **Notes**
    \(bootyNotes)
    """
    return Program("Booty-ful Beginnings/3 5-8", workouts, booty58Exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Booty-ful Beginnings/3 9-12")
}

// Weeks 9-12 for 3 days/week version of Booty-ful Beginnings.
func Bootyful3c() -> Program {
    let workouts = [
        Workout("A", booty912AExercises, scheduled: true, optional: []),
        Workout("B", booty912BExercises, scheduled: true, optional: []),
        Workout("C", booty912CExercises, scheduled: true, optional: []),
        
        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is the 3 days/week version of weeks 9-12 of the beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):
    
    **Workout A**
    \(booty912ADesc)
    
    **Cardio**
    
    **Workout B**
    \(booty912BDesc)
    
    **Cardio**
    
    **Workout C**
    \(booty912CDesc)
    
    **Cardio**
    
    **Rest**
    
    **Notes**
    \(bootyNotes)
    """
    return Program("Booty-ful Beginnings/3 9-12", workouts, booty912Exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Gluteal Goddess 1-4")
}

