import Foundation

func Phat() -> Program {
    let warmup = Warmups(withBar: 1, firstPercent: 0.5, lastPercent: 0.9, reps: [10, 5, 3])
    let speedWarmup = Warmups(withBar: 1, firstPercent: 0.6, lastPercent: 0.9, reps: [10, 5])
    let noWarmup = Warmups(withBar: 0, firstPercent: 0.6, lastPercent: 0.9, reps: [])
    
    let exercises = [
        // Upper Power
        barbell("Pendlay Row",        "Pendlay Row",          3, by: 5,  warmups: warmup, restMins: 3.0),
        bodyWeight("Pullups",         "Pullup",               requestedReps: 12, targetReps: 20, restMins: 3.0),
        bodyWeight("Rack Chinup 1",   "Rack Chinup",          requestedReps: 12, targetReps: 20, restMins: 2.5),
        dumbbell("Dumbbell Bench",    "Dumbbell Bench Press", 3, minReps: 3, maxReps: 5, warmups: noWarmup, restMins: 3.0),
        bodyWeight("Dips",            "Dips",                 2, minReps: 6, maxReps: 10, restMins: 2.5),
        dumbbell("Dumbbell OHP 1",    "Dumbbell Seated Shoulder Press", 3, minReps: 6, maxReps: 10, warmups: noWarmup, restMins: 2.5),
        barbell("Cambered Bar Curls", "Barbell Curl",         3, minReps: 6, maxReps: 10, warmups: noWarmup, restMins: 2.0),
        dumbbell("Skull Crushers",    "Skull Crushers",       3, minReps: 6, maxReps: 10, warmups: noWarmup, restMins: 2.0),

        // Lower Power
        barbell("Squat",                     "Low bar Squat",         3, by: 5, warmups: warmup, restMins: 3.0),
        barbell("Hack Squat",                "Hack Squat",            2, by: 10, warmups: warmup, restMins: 3.0),
        machine("Leg Extensions 1",          "Leg Extensions",        2, by: 10, warmups: noWarmup, restMins: 2.0),
        barbell("Stiff-Legged Deadlift",     "Stiff-Legged Deadlift", 3, by: 8, warmups: warmup, restMins: 3.0),
        machine("Leg Curls",                 "Seated Leg Curl",       2, by: 10, warmups: noWarmup, restMins: 2.0),
        pairedPlates("Standing Calf Raises", "Standing Calf Raises",  3, by: 10, warmups: noWarmup, restMins: 2.0),
        machine("Seated Calf Raises",        "Seated Calf Raises",    2, by: 10, warmups: noWarmup, restMins: 2.0),

        // Back and Shoulders
        barbell("Pendlay Row (speed)",    "Pendlay Row",                    6, by: 5,  warmups: speedWarmup, restMins: 1.5),
        bodyWeight("Rack Chinup 2",       "Rack Chinup",                    requestedReps: 24, targetReps: 36, restMins: 2.0),
        machine("Seated Cable Row",       "Seated Cable Row",               3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Dumbbell Shrug",        "Dumbbell Shrug",                 2, minReps: 12, maxReps: 15, warmups: noWarmup, restMins: 2.0),
        machine("Close-grip Pulldown",    "Lat Pulldown",                   2, minReps: 15, maxReps: 20, warmups: noWarmup, restMins: 2.0),
        dumbbell("Dumbbell OHP 2",        "Dumbbell Seated Shoulder Press", 3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        barbell("Upright Row",            "Upright Row",                    2, minReps: 12, maxReps: 15,  warmups: noWarmup, restMins: 2.0),
        dumbbell("Lateral Raises",        "Side Lateral Raise",             3, minReps: 12, maxReps: 20, warmups: noWarmup, restMins: 2.0),

        // Lower Body
        barbell("Squat (speed)",          "Low bar Squat",         6, by: 5, warmups: speedWarmup, restMins: 1.5),
        barbell("Hack Squat",             "Hack Squat",            3, by: 12, warmups: noWarmup, restMins: 2.0),
        pairedPlates("Leg Press",         "Leg Press",             2, by: 15, warmups: noWarmup, restMins: 2.0),
        machine("Leg Extensions 2",       "Leg Extensions",        3, by: 20, warmups: noWarmup, restMins: 2.0),
        barbell("Romanian Deadlift",      "Romanian Deadlift",     3, by: 12, warmups: noWarmup, restMins: 2.0),
        bodyWeight("Lying Leg Curls",     "Lying Leg Curls",       2, by: 15, restMins: 2.0),
        machine("Seated Leg Curls",       "Seated Leg Curl",       2, by: 20, warmups: noWarmup, restMins: 2.0),
        machine("Donkey Calf Raises",     "Donkey Calf Raises",    4, by: 15, warmups: noWarmup, restMins: 2.0),
        machine("Seated Calf Raises",     "Seated Calf Raises",    3, by: 20, warmups: noWarmup, restMins: 2.0),

        // Chest and Arms
        dumbbell("Dumbbell Bench (speed)", "Dumbbell Bench Press",        6, by: 5, warmups: noWarmup, restMins: 1.5),
        dumbbell("Incline Dumbbell Press", "Dumbbell Incline Press",      3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        machine("Hammer Chest Press",      "Hammer Strength Chest Press", 3, minReps: 12, maxReps: 15, warmups: noWarmup, restMins: 2.0),
        machine("Incline Cable Flye",      "Incline Cable Flye",          2, minReps: 15, maxReps: 20, warmups: noWarmup, restMins: 2.0),
        barbell("Preacher Curls",          "Preacher Curl",               3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Concentration Curls",    "Concentration Curls",         2, minReps: 12, maxReps: 15, warmups: noWarmup, restMins: 2.0),
        barbell("Spider Curls",            "Spider Curls",                2, minReps: 15, maxReps: 20, warmups: noWarmup, restMins: 2.0),
        dumbbell("Seated Triceps Press",   "Seated Triceps Press",        3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        machine("Triceps Pushdown",        "Triceps Pushdown (rope)",     2, minReps: 12, maxReps: 15, warmups: noWarmup, restMins: 2.0),
        machine("Cable Kickbacks",         "One-Legged Cable Kickback",   2, minReps: 15, maxReps: 20, warmups: noWarmup, restMins: 2.0)]
    
    let workouts = [
        Workout("Upper Power", ["Pendlay Row", "Pullups", "Rack Chinup 1", "Dumbbell Bench", "Dips", "Dumbbell OHP 1", "Cambered Bar Curls", "Skull Crushers"], scheduled: true, optional: []),
        Workout("Lower Power", ["Squat", "Hack Squat", "Leg Extensions 1", "Stiff-Legged Deadlift", "Leg Curls", "Standing Calf Raises", "Seated Calf Raises"], scheduled: true, optional: []),
        Workout("Back and Shoulders", ["Pendlay Row (speed)", "Rack Chinup 2", "Seated Cable Row", "Dumbbell Shrug", "Close-grip Pulldown", "Dumbbell OHP 2", "Upright Row", "Lateral Raises"], scheduled: true, optional: []),
        Workout("Lower Body", ["Squat (speed)", "Hack Squat", "Leg Press", "Leg Extensions 2", "Romanian Deadlift", "Lying Leg Curls", "Seated Leg Curls", "Donkey Calf Raises", "Seated Calf Raises"], scheduled: true, optional: []),
        Workout("Chest and Arms", ["Dumbbell Bench (speed)", "Incline Dumbbell Press", "Hammer Chest Press", "Incline Cable Flye", "Preacher Curls", "Concentration Curls", "Spider Curls", "Seated Triceps Press", "Triceps Pushdown", "Cable Kickbacks"], scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.intermediate, .hypertrophy, .barbell, .fiveDays, .unisex, .ageUnder40]
    let description = """
Dr. Layne Norton's [Power Hypertrophy Adaptive Training](http://www.simplyshredded.com/mega-feature-layne-norton-training-series-full-powerhypertrophy-routine-updated-2011.html) workout. This is a give day program where three of the days are body-builder style and two of the days are focused on increasing strength. The workouts are:

**Upper Power**
* Pendlay Rows 3x5
* Pullups 12-20
* Rack Chins 12-20
* Dumbbell Press 3x3-5
* Dips 2x6-10
* Seated Dumbbell OHP 3x6-10
* Cambered Bar Curls 3x6-10
* Skull Crushers 3x6-10

**Lower Power**
* Squat 3x5
* Hack Squats 2x10
* Leg Extensions 2x10
* Stiff-legged Deadlifts 3x8
* Leg Curls 2x10
* Standing Calf Raises 3x10
* Seated Calf Raises 2x10

**Back and Shoulders**
* Pendlay Row 6x5 (speed)
* Rack Chins 24-36
* Seated Cable Row 3x8-12
* Dumbbell Shrugs 2x12-15
* Close-grip Pulldowns 2x15-20
* Seated Dumbbell Press 3x8-12
* Upright Rows 2x12-15
* Lateral Raise 3x12-20

**Lower Body**
* Squat 6x5 (speed)
* Hack Squats 3x12
* Leg Press 2x15
* Leg Extensions 3x20
* Romanian Deadlift 3x12
* Lying Leg Curls 2x15
* Seated Leg Curls 2x20
* Donkey Calf Raises 4x15
* Seated Calf Raises 3x20

**Chest and Arms**
* Dumbbell Press 6x5 (speed)
* Incline Dumbbell Press 3x8-12
* Hammer Press 3x12-15
* Incline Cable Flyes 2x15-20
* Cambered Bar Preacher Curls 3x8-12
* Dumbbell Concentration Curls 2x12-15
* Spider Curls 2x15-20
* Seated Tricep Extension 3x8-12
* Cable Pressdown 2x12-15
* Cable Kickbacks 2x15-20

**Notes**
* For the speed sets use 65-70% of the power day weights and try to perform the lifts explosively while maintaining good form.
* Chains or bands can be helpful for the speed work.
* Leave one to two sets in the tank.
* Until you adjust to the workload you may want to skip some of the auxiliary exercises.
* A deload every 6-12 weeks is recommended: spend 1-3 weeks lifting at 60-70%.
"""
    return Program("PHAT", workouts, exercises, tags, description)
}


