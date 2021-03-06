import Foundation

let strongCurvesWarmups = [
    // AC Warmup
    bodyWeight("Foam Rolling",                 "IT-Band Foam Roll",               1, by: 10, restMins: 0.0),
    bodyWeight("Hamstring Stretch",            "Foot Elevated Hamstring Stretch", 2, secs: 30),
    bodyWeight("Psoas Stretch",                "Forward Lunge Stretch",           2, secs: 30),
    bodyWeight("Adductors",                    "Standing Wide Leg Straddle",      1, secs: 30),
    bodyWeight("Side Lying Abduction",         "Side Lying Abduction",            2, secs: 30),
    bodyWeight("Bird-dog",                     "Bird-dog",                        1, by: 8, restMins: 0.0),
    bodyWeight("Front Plank",                  "Front Plank",                     1, minSecs: 20, maxSecs: 120),
    bodyWeight("LYTP",                         "LYTP",                            1, by: 10, restMins: 0.0),
    bodyWeight("Walking Lunge",                "Body-weight Walking Lunge",       1, by: 10, restMins: 0.0),
    bodyWeight("Wall Ankle Mobility",          "Wall Ankle Mobility",             1, by: 10, restMins: 0.0),
    bodyWeight("Quadruped Thoracic Extension", "Quadruped Thoracic Extension",    1, by: 10, restMins: 0.0),
    bodyWeight("Rotational Lunge",             "Rotational Lunge",                1, by: 10, restMins: 0.0),
    
    // B Warmup
    bodyWeight("Tiger Tail Roller",             "Tiger Tail Roller",                1, by: 10, restMins: 0.0),
    bodyWeight("SMR Glutes with Ball",          "SMR Glutes with Ball",             1, by: 10, restMins: 0.0),
    bodyWeight("Standing Quad Stretch",         "Standing Quad Stretch",            2, secs: 30),
    bodyWeight("Seated Piriformis Stretch",     "Seated Piriformis Stretch",        2, secs: 30),
    bodyWeight("One-Handed Hang",               "One-Handed Hang",                  2, minSecs: 20, maxSecs: 30),
    bodyWeight("Pec Stretch",                   "Doorway Chest Stretch",            2, secs: 30),
    bodyWeight("Clam",                          "Clam",                             2, secs: 30),
    bodyWeight("Side Plank",                    "Side Plank",                       2, minSecs: 20, maxSecs: 60),
    bodyWeight("Pushup Plus",                   "Pushup Plus",                      1, by: 10, restMins: 0.0),
    bodyWeight("Wall Extensions",               "Wall Extensions",                  1, by: 10, restMins: 0.0),
    bodyWeight("Walking Knee Hugs",             "Walking Knee Hugs",                1, by: 10, restMins: 0.0),
    // omitted Superman per https://www.duncansportspt.com/2015/07/superman-exercise
    bodyWeight("Squat to Stand",                "Squat to Stand",                   1, by: 10, restMins: 0.0),
    bodyWeight("Swiss Ball Internal Rotation",  "Swiss Ball Hip Internal Rotation", 1, by: 10, restMins: 0.0),
]

fileprivate let booty14Exercises = [
    // A
    bodyWeight("Glute Bridge",             "Glute Bridge",               3, minReps: 10, maxReps: 20, restMins: 0.5),
    dumbbell("One Arm Row",                "Kroc Row",                   3, minReps: 8, maxReps: 12, restMins: 0.5),
    bodyWeight("Box Squat",                "Body-weight Box Squat",      3, minReps: 10, maxReps: 20, restMins: 1.0),
    dumbbell("Dumbbell Bench Press",       "Dumbbell Bench Press",       3, minReps: 8, maxReps: 12, restMins: 1.0),
    dumbbell("Dumbbell Romanian Deadlift", "Dumbbell Romanian Deadlift", 3, minReps: 10, maxReps: 20, restMins: 1.0),
    bodyWeight("Side Lying Abduction",     "Side Lying Abduction",       2, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Front Plank",              "Front Plank",                1, minSecs: 20, maxSecs: 120),
    bodyWeight("Side Plank from Knees",    "Side Plank",                 2, minSecs: 20, maxSecs: 60),
    
    // B
    // Glute Bridge
    machine("Lat Pulldown",       "Lat Pulldown",            3, minReps: 8, maxReps: 12, restMins: 1.0),
    bodyWeight("Step-up",         "Step-ups",                3, minReps: 10, maxReps: 20, restMins: 0.5),
    dumbbell("Dumbbell OHP",      "Dumbbell Shoulder Press", 3, minReps: 8, maxReps: 12, restMins: 1.0),
    bodyWeight("Back Extension",  "Back Extension",          3, minReps: 10, maxReps: 20, restMins: 0.5),
    bodyWeight("Side Lying Clam", "Clam",                    1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Crunch",          "Situp",                   1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Side Crunch",     "Oblique Crunches",        1, minReps: 15, maxReps: 30, restMins: 0.5),
    
    // C
    bodyWeight("Glute March",          "Glute March",                     3, secs: 60),
    machine("Seated Row",              "Seated Cable Row",                3, minReps: 8, maxReps: 12, restMins: 1.0),
    bodyWeight("Body-weight Squat",    "Body-weight Squat",               3, minReps: 10, maxReps: 20, restMins: 1.0),
    dumbbell("Dumbbell Incline Press", "Dumbbell Incline Press",          3, minReps: 8, maxReps: 12, restMins: 1.0),
    bodyWeight("Romanian Deadlift",    "Body-weight Single Leg Deadlift", 3, minReps: 10, maxReps: 20, restMins: 0.5),
    bodyWeight("X-Band Walk",          "X-Band Walk",                     1, minReps: 10, maxReps: 20, restMins: 0.5),
    bodyWeight("RKC Plank",            "RKC Plank",                       1, minSecs: 10, maxSecs: 30),
    machine("Rope Horizontal Chop",    "Rope Horizontal Chop",            1, minReps: 5, maxReps: 10, restMins: 0.5),
    ] + strongCurvesWarmups

fileprivate let booty58Exercises = [
    // A
    bodyWeight("Hip Thrust",              "Body-weight Hip Thrust",               3, minReps: 10, maxReps: 20, restMins: 0.5),
    machine("One Arm Cable Row",          "Standing One Arm Cable Row",           3, minReps: 8, maxReps: 12, restMins: 0.5),
    bodyWeight("Step Up + Reverse Lunge", "Body-weight Step Up + Reverse Lunge",  3, minReps: 10, maxReps: 20, restMins: 0.5),
    barbell("Bench Press",                "Bench Press",                          3, minReps: 8, maxReps: 12, restMins: 2.0),
    barbell("Romanian Deadlift",          "Romanian Deadlift",                    3, minReps: 10, maxReps: 20, restMins: 2.0),
    bodyWeight("Side Lying Abduction",    "Side Lying Abduction",                 1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Decline Plank",           "Decline Plank",                        1, minSecs: 20, maxSecs: 60),
    bodyWeight("Side Plank",              "Side Plank",                           2, minSecs: 20, maxSecs: 60),
    
    // B
    bodyWeight("Glute Bridge",           "Glute Bridge",              3, minReps: 10, maxReps: 20, restMins: 0.5),
    bodyWeight("Negative Chinup",        "Chinup",                    3, by: 3, restMins: 1.0),
    bodyWeight("Walking Lunge",          "Body-weight Walking Lunge", 3, minReps: 10, maxReps: 20, restMins: 1.0),
    dumbbell("Dumbbell OHP",             "Dumbbell Shoulder Press",   3, minReps: 8, maxReps: 12, restMins: 1.0),
    bodyWeight("Reverse Hyperextension", "Reverse Hyperextension",    3, minReps: 10, maxReps: 20, restMins: 0.5),
    bodyWeight("Clam",                   "Clam",                      1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Swiss Ball Crunch",      "Exercise Ball Crunch",      1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Swiss Ball Side Crunch", "Exercise Ball Side Crunch", 1, minReps: 15, maxReps: 30, restMins: 0.5),
    
    // C
    bodyWeight("Hip Thrust (paused)", "Hip Thrust (rest pause)",  3, minReps: 10, maxReps: 20, restMins: 0.5),
    bodyWeight("Inverted Row",        "Inverted Row",             3, minReps: 8, maxReps: 12, restMins: 0.5),
    dumbbell("Goblet Squat",          "Goblet Squat",             3, minReps: 10, maxReps: 20, restMins: 2.0),
    barbell("Close-Grip Bench Press", "Close-Grip Bench Press",   3, minReps: 8, maxReps: 12, restMins: 2.0),
    bodyWeight("Kettlebell Swing",    "Kettlebell Two Arm Swing", 3, minReps: 10, maxReps: 20, restMins: 0.5),
    bodyWeight("X-Band Walk",         "X-Band Walk",              1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Straight Leg Situp",  "Straight Leg Situp",       1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Anti-Rotary Hold",    "Band Anti-Rotary Hold",    2, minSecs: 10, maxSecs: 20),
    ] + strongCurvesWarmups

fileprivate let booty912Exercises = [
    // A
    barbell("Hip Thrust",              "Hip Thrust",             3, minReps: 10, maxReps: 20, restMins: 1.0),
    dumbbell("Dumbbell Row",           "Bent Over Dumbbell Row", 3, minReps: 8, maxReps: 12, restMins: 1.0),
    barbell("Box Squat",               "Box Squat",              3, minReps: 10, maxReps: 20, restMins: 2.0),
    bodyWeight("Pushup",               "Pushup",                 3, minReps: 3, maxReps: 10, restMins: 0.5),
    barbell("Deadlift",                "Deadlift",               3, minReps: 10, maxReps: 20, restMins: 2.0),
    bodyWeight("Side Lying Abduction", "Side Lying Abduction",   1, minReps: 15, maxReps: 30, restMins: 0.5),
    dumbbell("Dumbbell Ball Crunch",   "Exercise Ball Crunch",   1, minReps: 15, maxReps: 30, restMins: 0.5),
    machine("Anti-Rotation Press",     "Half-kneeling Cable Anti-Rotation Press", 1, minReps: 10, maxReps: 15, restMins: 0.5),

    // B
    bodyWeight("Single Leg Hip Thrust", "Body-weight Single Leg Hip Thrust", 3, minReps: 10, maxReps: 20, restMins: 1.0),
    bodyWeight("Chinup",                "Chinup",                            3, minReps: 1, maxReps: 5, restMins: 1.0),
    bodyWeight("Bulgarian Split Squat", "Body-weight Bulgarian Split Squat", 3, minReps: 10, maxReps: 20, restMins: 1.0),
    dumbbell("One Arm OHP",             "Dumbbell One Arm Shoulder Press",   3, minReps: 8, maxReps: 12, restMins: 1.0),
    barbell("Good Morning",             "Good Morning",                      3, minReps: 10, maxReps: 20, restMins: 1.0),
    bodyWeight("X-Band Walk",           "X-Band Walk",                       1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Decline Plank",         "Decline Plank",                     1, minSecs: 60, maxSecs: 120),
    dumbbell("Side Bend",               "Dumbbell Side Bend",                1, minReps: 15, maxReps: 30, restMins: 1.0),

    // C
    barbell("Hip Thrust (paused)",   "Hip Thrust (rest pause)", 3, minReps: 8, maxReps: 12, restMins: 1.0),
    dumbbell("Incline Row",          "Dumbbell Incline Row",    3, minReps: 8, maxReps: 12, restMins: 1.0),
    barbell("Squat",                 "Low bar Squat",           3, minReps: 10, maxReps: 20, restMins: 2.0),
    barbell("Incline Bench Press",   "Incline Bench Press",     3, minReps: 3, maxReps: 10, restMins: 2.0),
    bodyWeight("Back Extension",     "Back Extension",          3, minReps: 10, maxReps: 30, restMins: 0.5),
    bodyWeight("Clam",               "Clam",                    1, minReps: 15, maxReps: 30, restMins: 0.5),
    bodyWeight("Hanging Leg Raise",  "Hanging Leg Raise",       1, minReps: 10, maxReps: 20, restMins: 0.5),
    machine("Rope Horizontal Chop", "Rope Horizontal Chop",     1, minReps: 10, maxReps: 15, restMins: 0.5),
] + strongCurvesWarmups

fileprivate let booty14AExercises = ["Glute Bridge", "One Arm Row", "Box Squat", "Dumbbell Bench Press", "Dumbbell Romanian Deadlift", "Side Lying Abduction", "Front Plank", "Side Plank from Knees"]
fileprivate let booty14BExercises = ["Glute Bridge", "Lat Pulldown", "Step-up", "Dumbbell OHP", "Back Extension", "Side Lying Clam", "Crunch", "Side Crunch"]
fileprivate let booty14CExercises = ["Glute March", "Seated Row", "Body-weight Squat", "Dumbbell Incline Press", "Romanian Deadlift", "X-Band Walk", "RKC Plank", "Rope Horizontal Chop"]

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
* Side Lying Abduction 2x15-30 (per side)
* Front Plank 1x20-120s
* Side Plank from Knees 1x20-60s (per side)
"""

fileprivate let booty14BDesc = """
* Bodyweight Single-leg Glute Bridge 3x10-20 (set per side)
* Lat Pulldown 3x8-12
* Bodyweight Step-up 3x10-20 (per side)
* Dumbbell Overhead Press 3x8-12
* Back Extension 3x10-20
* Side Lying Clam 1x15-30 (per side)
* Crunch 1x15-30
* Side Crunch 1x15-30 (per side)
"""

fileprivate let booty14CDesc = """
* Glute March 3x60s
* Seated Row 3x8-12
* Bodyweight Squat 3x10-20
* Dumbbell Incline Press 3x8-12
* Bodyweight Romanian Deadlift 3x10-20 (per side)
* X-Band Walk (light tension) 1x10-20 steps (per side)
* RKC Plank 1x10-30s
* Rope Horz Chop 1x5-10 (per side)
"""

fileprivate let booty58ADesc = """
* Bodyweight Hip Thrust 3x10-20
* Standing Single-arm Cable-row 3x8-12
* Bodyweight Step up/Reverse lunge 3x10-20
* Bench Press 3x8-12
* Romanian Deadlift 3x10-20
* Side Lying Abduction 1x15-30
* Feet Elevated Plank 1x20-60s
* Side Plank 1x20-60s
"""

fileprivate let booty58BDesc = """
* Bodyweight Single-leg Glute Bridge 3x-10-20 (per side)
* Negative Chinup 3x3 (or lat pulldown)
* Bodyweight Walking Lunge 3x10-20
* Dumbbell OHP 3x8-12
* Bodyweight Reverse Hyper 3x10-20
* Side Lying Clam 1x15-30 (per side)
* Swiss Ball Crunch 1x15-30
* Swiss Ball Side Crunch 1x15-30
"""

fileprivate let booty58CDesc = """
* Bodyweight Hip thrust 3x10-20 (paused)
* Modified Inverted Row 3x8-12
* Goblet squat 3x10-20
* Close-grip Bench Press 3x8-12
* Russian Kettlebell Swing 3x10-20
* X-band Walk (moderate) 1x15-30 (per side)
* Straight-leg Situp 1x15-30
* Band Rotary Hold 1x10-20s (per side)
"""

fileprivate let booty912ADesc = """
* Barbell Hip Thrust 3x10-20
* Dumbbell Bent Over Row 3x8-12
* Barbell Box Squat 3x10-20
* Push-up 3x3-10
* Barbell Deadlift 3x10-20
* Side Lying Abduction 1x15-30 (per side)
* Dumbbell Swiss Ball Crunch 1x15-30 (per side)
* Half-kneeling Cable Anti-Rotation Press 1x10-15 (per side)
"""

fileprivate let booty912BDesc = """
* Bodyweight Single-leg Hip Thrust (shoulders elevated) 3x10-20 (per side)
* Chin-up (or assisted) 3x1-5
* Bodyweight Bulgarian Split Squat 3x10-20
* Single-arm Dumbbell OHP 3x8-12
* Barbell Good Morning 3x10-20
* X-band Walk (moderate) 1x15-30 (per side)
* Feet Elevated Plank 1x60-120s
* Dumbbell Side Bend 1x15-30 (per side)
"""

fileprivate let booty912CDesc = """
* Barbell Hip Thrust (paused) 3x8-12
* Dumbbell Chest Supported Row 3x8-10
* Barbell Squat 3x10-20
* Incline Press 3x3-10
* Bodyweight Back Extension 3x10-30
* Side Lying Clam 1x15-30 (per side)
* Hanging Leg Raise 1x10-20
* Rope Horizontal Chop 1x10-15 (per side)
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

