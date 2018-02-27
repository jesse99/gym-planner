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

fileprivate func planWeighted3to8() -> Plan {
    let numSets = 3
    let minReps = 3
    let maxReps = 8
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

fileprivate func planWeighted1_8to12() -> Plan {
    let numSets = 1
    let minReps = 8
    let maxReps = 12
    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
}

//fileprivate func planWeighted5to10() -> Plan {
//    let numSets = 1
//    let minReps = 5     // this called for 1x10 which seems silly
//    let maxReps = 10
//    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
//    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
//}
//
fileprivate func planWeighted10to20() -> Plan {
    let numSets = 3
    let minReps = 10
    let maxReps = 20
    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
}

//fileprivate func planWeighted10to15() -> Plan {
//    let numSets = 3
//    let minReps = 10
//    let maxReps = 15
//    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
//    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
//}
//
//fileprivate func planWeighted15to30() -> Plan {
//    let numSets = 3
//    let minReps = 14
//    let maxReps = 30
//    let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
//    return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
//}

func planLinear(_ numSets: Int, by: Int) -> Plan {
    let warmups = Warmups(withBar: 0, firstPercent: 0.5, lastPercent: 0.9, reps: [])
    return LinearPlan("\(numSets)x\(by)", warmups, workSets: numSets, workReps: by)
}

fileprivate let glutealNotes = """
* This program should be started once you have built a base of strength using a program like Booty-ful Beginnings.
* Attempt to increase weights by 5-10 pounds each week.
* Bret recommends spending 10-15 minutes warming up before each workout.
* When foam rolling Bret recommends hitting the erectors, quads, IT Band, hip flexors, hamsttrings, adductors, glutes, calves, and lats.
* For the Stick/Tiger Tail roller warmup hit the IT-band, quads, calves, and shins.
* Focus on activating the glutes with each exercise.
* When performing a single leg/arm exercise begin with the weaker limb and then do the same number of reps with the stronger limb.
* If you're having an off day don't continue a set if your form begins to break down.
* To speed up the workouts you can superset the exercises: do a set of a lower body exercise, a set of an upper body, rest for 60-120s, and repeat until you've finished all the sets for both exercises.
* Once you've done all the indicated workouts the app will prompt you to move onto the next program.
"""

// Weeks 1-4 for 3 days/week version of Gluteal Goddess.
func GlutealGoddess1() -> Program {
    let exercises = [
        // A
        createBarBell("Glute Bridge",             "Glute Bridge",           planLinear(3, by: 20), restMins: 2.0),
        createDumbbell2("One Arm Row",            "Kroc Row",               planLinear(3, by: 8), restMins: 1.0),
        createBarBell("Box Squat",                "Body-weight Box Squat",  planLinear(3, by: 5), restMins: 2.0),
        createDumbbell2("Dumbbell Incline Press", "Dumbbell Incline Press", planLinear(3, by: 8), restMins: 1.0),
        createBarBell("Deadlift",                 "Deadlift",               planLinear(3, by: 8), restMins: 2.0),
        createMachine("Cable Hip Abduction",      "Cable Hip Abduction",    planLinear(1, by: 20), restMins: 0.5),
        createTimed("RKC Plank",                  "RKC Plank",              planTimed(1, targetTime: 60), duration: 60),
        createTimed("Side Plank",                 "Side Plank",             planTimed(2, targetTime: 60), duration: 60),

        // B
        createVarReps("Single Leg Hip Thrust",   "Body-weight Single Leg Hip Thrust", planVarying(3, 8, 20), restMins: 1.0, requestedReps: 8),
        createFixed("Chinup",                    "Chinup",                            planFixed(3, 5), restMins: 2.0),
        createDumbbell2("Dumbbell Step Up",      "Deep Step-ups",                     planLinear(3, by: 10), restMins: 2.0),
        createBarBell("Overhead Press",          "Overhead Press",                    planLinear(3, by: 8), restMins: 2.0),
        createFixed("Prisoner Back Extension",   "Back Extension",                    planFixed(2, 12), restMins: 1.0),
        createFixed("Band Seated Abduction",     "Band Seated Abduction",             planFixed(1, 20), restMins: 1.0),
        createFixed("Straight-leg Situp",        "Straight Leg Situp",                planFixed(1, 20), restMins: 1.0),
        createFixed("Side Bend",                 "Side Bend (45 degree)",             planFixed(1, 20), restMins: 1.0),

        // C
        createBarBell("Hip Thrust",             "Hip Thrust",                   planLinear(3, by: 20), restMins: 2.0),
        createMachine("One Arm Cable Row",      "Standing One Arm Cable Row",   planLinear(3, by: 8), restMins: 1.0),
        createDumbbell2("Goblet Squat",         "Goblet Squat",                 planLinear(3, by: 5), restMins: 2.0),
        createDumbbell2("One Arm Bench Press",  "Dumbbell One Arm Bench Press", planLinear(3, by: 8), restMins: 1.0),
        createMachine("Pull Through",           "Pull Through",                 planVarying(3, 8, 12), restMins: 1.0),
        createFixed("Side Lying Hip Raise",     "Side Lying Hip Raise",         planFixed(1, 10), restMins: 1.0),
        createFixed("Turkish Get-Up",           "Turkish Get-Up",               planFixed(1, 5), restMins: 1.0),
        createMachine("Anti-Rotation Press",    "Half-kneeling Cable Anti-Rotation Press", planVarying(1, 8, 12), restMins: 2.0),
        ] + strongCurvesWarmups
    
    let aExercises = ["Glute Bridge", "One Arm Row", "Box Squat", "Dumbbell Incline Press", "Deadlift", "Cable Hip Abduction", "RKC Plank", "Side Plank"]
    let bExercises = ["Single Leg Hip Thrust", "Chinup", "Dumbbell Step Up", "Overhead Press", "Prisoner Back Extension", "Band Seated Abduction", "Straight-leg Situp", "Side Bend"]
    let cExercises = ["Hip Thrust", "One Arm Cable Row", "Goblet Squat", "One Arm Bench Press", "Pull Through", "Side Lying Hip Raise", "Turkish Get-Up", "Anti-Rotation Press"]
    
    let workouts = [
        Workout("A", aExercises, scheduled: true, optional: []),
        Workout("B", bExercises, scheduled: true, optional: []),
        Workout("C", cExercises, scheduled: true, optional: []),
        
        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.intermediate, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is the weeks 1-4 of the intermediate program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):
    
    **Workout A**
    * Barbell Glute Bridge 3x20
    * One Arm Row 3x8 (each side)
    * Barbell Box Squat 3x5
    * Dumbbell Incline Press 3x8
    * Deadlift 3x8
    * Cable Standing Abduction 1x20 (each side)
    * RKC Plank 1x60s
    * Side Plank 2x60s (set per side)

    **Cardio**
    
    **Workout B**
    * Bodyweight Shoulder Elevated Single-leg Hip Thrust 3x8-20 (each side)
    * Chinup 3x5
    * Dumbbell High Step-up 3x10 (each side)
    * Barbell Overhead Press 3x8
    * Prisoner Back Extension 2x12
    * Band Seated Abduction 1x20
    * Straight-leg Situp 1x20
    * 45-degree Side Bend 1x20

    **Cardio**
    
    **Workout C**
    * Barbell Hip Thrust 3x20
    * Standing Single-arm Cable Row 3x8 (each side)
    * Goblet Squat 3x5
    * Single Arm Bench Press 3x8
    * Cable Straight-leg Pull-Through 3x8-12
    * Side-lying Hip Raise 1x10 (each side)
    * Turkish Get Up 1x5 (each side)
    * Half-kneeling Cable Anti-rotation Press 1x8-12 (each side)

    **Cardio**
    
    **Rest**
    
    **Notes**
    \(glutealNotes)
    """
    return Program("Gluteal Goddess 1-4", workouts, exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Gluteal Goddess 5-8")
}

// Weeks 5-8 for 3 days/week version of Gluteal Goddess.
func GlutealGoddess2() -> Program {
    let exercises = [
        // A
        createBarBell("Hip Thrust",              "Hip Thrust",              planWeighted3to8(), restMins: 2.0),
        createMachine("Seated Row",              "Seated Cable Row",        planLinear(3, by: 8), restMins: 1.0),
        createBarBell("Squat",                   "Low bar Squat",           planLinear(3, by: 5), restMins: 2.0),
        createBarBell("Bench Press",             "Bench Press",             planWeighted3to8(), restMins: 2.0),
        createBarBell("Good Morning",            "Good Morning",            planWeighted8to12(), restMins: 2.0),
        createVarReps("Band Standing Abduction", "Band Standing Abduction", planVarying(1, 10, 30), restMins: 1.0, requestedReps: 10),
        createVarReps("Ab Wheel Rollout",        "Ab Wheel Rollout",        planVarying(1, 8, 20), restMins: 1.0, requestedReps: 8),
        createDumbbell2("Dumbbell Side Bend",    "Dumbbell Side Bend",      planWeighted10to20(), restMins: 1.0),
        
        // B
        createVarReps("Single Leg Hip Thrust", "Body-weight Single Leg Hip Thrust", planVarying(3, 8, 20), restMins: 1.0, requestedReps: 8),
        createVarReps("Pullup",                "Pullup",                            planVarying(3, 3, 8), restMins: 2.0, requestedReps: 3),
        createDumbbell2("Dumbbell Lunge",      "Dumbbell Lunge",                    planLinear(3, by: 10), restMins: 2.0),
        createBarBell("Push Press",            "Push Press",                        planLinear(3, by: 6), restMins: 2.0),
        createFixed("Dumbbell Back Extension", "Back Extension",                    planFixed(2, 20), restMins: 1.0),
        createVarReps("Band Seated Abduction", "Band Seated Abduction",             planVarying(1, 10, 30), restMins: 1.0, requestedReps: 10),
        createVarReps("Hanging Leg Raise",     "Hanging Leg Raise",                 planVarying(1, 8, 20), restMins: 1.0, requestedReps: 8),
        createSinglePlates("Landmine 180's",   "Landmine 180's",                    planWeighted1_8to12(), restMins: 1.0),

        // C
        createBarBell("Hip Thrust (isohold)",         "Hip Thrust (isohold)",         planLinear(3, by: 1), restMins: 2.0),
        createMachine("D-handle Lat Pulldown",        "Lat Pulldown",                 planLinear(3, by: 8), restMins: 1.0),
        createFixed("Skater Squat",                   "Skater Squat",                 planFixed(3, 8), restMins: 1.0),
        createVarReps("Narrow-base Pushup",           "Pushup",                       planVarying(3, 5, 15), restMins: 2.0, requestedReps: 5),
        createBarBell("Single-leg Romanian Deadlift", "Single Leg Romanian Deadlift", planWeighted8to12(), restMins: 2.0),
        createVarReps("Side Lying Hip Raise",         "Side Lying Hip Raise",         planVarying(1, 10, 30), restMins: 1.0, requestedReps: 10),
        createVarReps("Straight-leg Situp",           "Straight Leg Situp",           planVarying(1, 10, 20), restMins: 1.0, requestedReps: 10),
        createVarReps("Side Bend",                    "Side Bend (45 degree)",        planVarying(1, 10, 20), restMins: 1.0, requestedReps: 10),
        ] + strongCurvesWarmups

    let aExercises = ["Hip Thrust", "Seated Row", "Squat", "Bench Press", "Good Morning", "Band Standing Abduction", "Ab Wheel Rollout", "Dumbbell Side Bend"]
    let bExercises = ["Single Leg Hip Thrust", "Pullup", "Dumbbell Lunge", "Push Press", "Dumbbell Back Extension", "Band Seated Abduction", "Hanging Leg Raise", "Landmine 180's"]
    let cExercises = ["Hip Thrust (isohold)", "D-handle Lat Pulldown", "Skater Squat", "Narrow-base Pushup", "Single-leg Romanian Deadlift", "Side Lying Hip Raise", "Straight-leg Situp", "Side Bend"]
    
    let workouts = [
        Workout("A", aExercises, scheduled: true, optional: []),
        Workout("B", bExercises, scheduled: true, optional: []),
        Workout("C", cExercises, scheduled: true, optional: []),
        
        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
        ]
    
    let tags: [Program.Tags] = [.intermediate, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is the 3 days/week version of weeks 5-8 of the intermediate program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):
    
    **Workout A**
    Barbell Hip Thrust 3x3-8
    Seated Row 3x8
    Barbell Squat 3x5
    Bench Press 3x3-8
    Good Morning 3x8-12
    Band Standing Abduction 1x10-30 (set per side)
    Ab Wheel Rollout from Knees 1x8-20
    Dumbbell Side Bend 1x10-20 (set per side)

    **Cardio**
    
    **Workout B**
    Bodyweight Single-leg Hip Thrust (shoulder and foot elevated) 3x8-20
    Pullup 3x3-8
    Dumbbell Walking Lunge 3x10
    Push Press 3x6
    Dumbbell Back Extension 2x20
    Band Seated Abduction 1x10-30
    Hanging Leg Raise 1x8-20
    Landmine 180's 1x8-12 (set per side)

    **Cardio**
    
    **Workout C**
    Barbell Hip Thrust (isohold) 3x30-60s
    D-handle Lat Pulldowns 3x8
    Skater Squat 3x8
    Narrow-base Pushup 3x5-15
    Barbell Single-leg Romanian Deadlift 3x8-12
    Side-lying Hip Raise 1x10-30
    Straight-leg Situp 1x10-20
    45-degree Side Bend 1x10-20 (set per side)

    **Cardio**
    
    **Rest**
    
    **Notes**
    \(glutealNotes)
    """
    return Program("Gluteal Goddess 5-8", workouts, exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Gluteal Goddess 9-12")
}

// Weeks 9-12 for 3 days/week version of Gluteal Goddess.
//func GlutealGoddess3() -> Program {
//    let exercises = [
//        // A
//        createBarBell("Hip Thrust",           "Hip Thrust",             planWeighted10to20(), restMins: 1.0),
//        createDumbbell2("Dumbbell Row",       "Bent Over Dumbbell Row", planWeighted8to12(), restMins: 1.0),
//        createBarBell("Box Squat",            "Box Squat",              planWeighted10to20(), restMins: 2.0),
//        createVarReps("Pushup",               "Pushup",                 planVarying(3, 3, 10), restMins: 0.5, requestedReps: 3),
//        createBarBell("Deadlift",             "Deadlift",               planWeighted10to20(), restMins: 2.0),
//        createVarReps("Side Lying Abduction", "Side Lying Abduction",   planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
//        createVarReps("Dumbbell Ball Crunch", "Exercise Ball Crunch",   planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
//        createMachine("Anti-Rotation Press",  "Half-kneeling Cable Anti-Rotation Press", planWeighted10to15(), restMins: 0.5),
//        
//        // B
//        createVarReps("Single Leg Hip Thrust", "Body-weight Single Leg Hip Thrust", planVarying(3, 20, 20), restMins: 1.0, requestedReps: 10),
//        createVarReps("Chinup",                "Chinup",                            planVarying(3, 1, 5), restMins: 1.0, requestedReps: 1),
//        createVarReps("Bulgarian Split Squat", "Body-weight Bulgarian Split Squat", planVarying(3, 10, 20), restMins: 1.0, requestedReps: 10),
//        createDumbbell2("One Arm OHP",         "Dumbbell One Arm Shoulder Press",   planWeighted8to12(), restMins: 1.0),
//        createBarBell("Good Morning",          "Good Morning",                      planWeighted10to20(), restMins: 1.0),
//        createVarReps("X-Band Walk",           "X-Band Walk",                       planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
//        createTimed("Decline Plank",           "Decline Plank",                     planTimed(1, targetTime: 120), duration: 60),
//        createDumbbell2("Side Bend",           "Dumbbell Side Bend",                planWeighted15to30(), restMins: 1.0),
//        
//        // C
//        createBarBell("Hip Thrust (paused)",   "Hip Thrust",             planWeighted8to12(), restMins: 1.0),
//        createDumbbell2("Incline Row",         "Dumbbell Incline Row",   planWeighted8to12(), restMins: 1.0),
//        createBarBell("Squat",                 "Low bar Squat",          planWeighted10to20(), restMins: 2.0),
//        createBarBell("Incline Bench Press",   "Incline Bench Press",    planWeighted3to10(), restMins: 2.0),
//        createVarReps("Back Extension",        "Back Extension",         planVarying(3, 10, 30), restMins: 0.5, requestedReps: 10),
//        createVarReps("Clam",                  "Clam",                   planVarying(1, 15, 30), restMins: 0.5, requestedReps: 15),
//        createVarReps("Hanging Leg Raise",     "Hanging Leg Raise",      planVarying(1, 10, 20), restMins: 0.5, requestedReps: 10),
//        createMachine("Rope Horizontal Chop",  "Rope Horizontal Chop",   planWeighted10to15(), restMins: 0.5),
//        ] + strongCurvesWarmups
//    
//    let aExercises = ["Hip Thrust", "Dumbbell Row", "Box Squat", "Pushup", "Deadlift", "Side Lying Abduction", "Dumbbell Ball Crunch", "Anti-Rotation Press"]
//    let bExercises = ["Single Leg Hip Thrust", "Chinup", "Bulgarian Split Squat", "One Arm OHP", "Good Morning", "X-Band Walk", "Decline Plank", "Side Bend"]
//    let cExercises = ["Hip Thrust (paused)", "Incline Row", "Squat", "Incline Bench Press", "Back Extension", "Clam", "Hanging Leg Raise", "Rope Horizontal Chop"]
//    
//    let workouts = [
//        Workout("A", aExercises, scheduled: true, optional: []),
//        Workout("B", bExercises, scheduled: true, optional: []),
//        Workout("C", cExercises, scheduled: true, optional: []),
//        
//        Workout("AC warmup", strongCurvesACWarmup, scheduled: false, optional: []),
//        Workout("B warmup", strongCurvesBWarmup, scheduled: false, optional: []),
//        ]
//    
//    let tags: [Program.Tags] = [.intermediate, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
//    let description = """
//    This is the 3 days/week version of weeks 9-12 of the intermediate program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows (Bret recommends warmups, and they are part of the program, but there are a lot so they aren't listed here):
//    
//    **Workout A**
//    Barbell Hip Thrust 3x10-20
//    Dumbbell Bent Over Row 3x8-12
//    Barbell Box Squat 3x10-20
//    Push-up 3x-3-10
//    Barbell Deadlift 3x10-20
//    Side Lying Abduction 1x15-30 (set pet side)
//    Dumbbell Swiss Ball Crunch 1x-15-30 (set pet side)
//    Half-kneeling Cable Anti-Rotation Press 1x10-15 (set per side)
//
//    **Cardio**
//    
//    **Workout B**
//    Bodyweight Single-leg Hip Thrust (shoulders elevated) 3x10-20 (set per side)
//    Chin-up (or assisted) 3x1-5
//    Bodyweight Bulgarian Split Squat 3x10-20
//    Single-arm Dumbbell OHP 3x8-12
//    Barbell Good Morning 3x10-20
//    X-band Walk (moderate) 1x15-30 (set per side)
//    Feet Elevated Plank 1x60-120s
//    Dumbbell Side Bend 1x15-30 (set per side)
//
//    **Cardio**
//    
//    **Workout C**
//    Barbell Hip Thrust (paused) 3x8-12
//    Dumbbell Chest Supported Row 3x8-10
//    Barbell Squat 3x10-20
//    Incline Press 3x3-10
//    Bodyweight Back Extension 3x10-30
//    Side Lying Clam 1x15-30 (set pet side)
//    Hanging Leg Raise 1x10-20
//    Rope Horizontal Chop 1x10-15 (set per side)
//
//    **Cardio**
//    
//    **Rest**
//    
//    **Notes**
//    \(glutealNotes)
//    """
//    return Program("Gluteal Goddess 9-12", workouts, exercises, tags, description)
//}


