import Foundation

fileprivate let noWarmup = Warmups(withBar: 0, firstPercent: 0.6, lastPercent: 0.9, reps: [])

fileprivate let exercises = [
    // Push
    dumbbell("Bench Press",               "Dumbbell Bench Press",   3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.5),
    dumbbell("Incline Fly",               "Dumbbell Incline Flyes", 3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.5),
    dumbbell("Arnold Press",              "Arnold Press",           3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.5),
    dumbbell("Overhead Tricep Extension", "Seated Triceps Press",   3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.5),
    bodyWeight("Hanging Leg Raise",       "Hanging Leg Raise",      3, minReps: 6, maxReps: 12, restMins: 1.0),
    
    // Pull
    bodyWeight("Pullup",      "Pullup",                 requestedReps: 3, targetReps: 30, restMins: 1.0),
    dumbbell("Bent-over Row", "Bent Over Dumbbell Row", 3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.5),
    dumbbell("Reverse Fly",   "Reverse Flyes",          3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.5),
    dumbbell("Shrug",         "Dumbbell Shrug",         3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.5),
    dumbbell("Curl",          "Concentration Curls",    3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.5),
    
    // Legs
    dumbbell("Goblet Squat",        "Goblet Squat",                   3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.0),
    dumbbell("Lunge",               "Dumbbell Lunge",                 3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.0),
    dumbbell("Single-leg Deadlift", "Kettlebell One-Legged Deadlift", 3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.0),
    dumbbell("Calf Raise",          "Standing Dumbbell Calf Raises",  3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 1.0)]

fileprivate let notes = """

**Notes**
* Start with the lightest weights you have available.
* Rest between each workout, rest for two days after the leg workout.
* For exercises that use one arm, count reps seperately for each arm (so 5 reps is 5 with one arm and then 5 with the other arm).
"""

func PPLStopgap4() -> Program {
    let workouts = [
        Workout("Push", ["Bench Press", "Incline Fly", "Arnold Press", "Overhead Tricep Extension", "Hanging Leg Raise"], scheduled: true, optional: []),
        Workout("Pull", ["Pullup", "Lunge", "Bent-over Row", "Reverse Fly", "Shrug", "Curl"], scheduled: true, optional: []),
        Workout("Legs", ["Goblet Squat", "Lunge", "Single-leg Deadlift", "Calf Raise"], scheduled: true, optional: [])]

    let tags: [Program.Tags] = [.beginner, .strength, .dumbbell, .fourDays, .unisex, .ageUnder40, .age50s]
    let description = """
Beginner strength [program](https://www.reddit.com/r/Fitness/comments/2e79y4/dumbbell_ppl_proposed_alternative_to_dumbbell) using only dumbbells. Note that you should have a bench and a pullup bar. Not quite as effective as the programs that use barbells (especially for the lower body) but way better than nothing.

**Push**
* Bench Press 3x6-12
* Incline Fly 3x6-12
* Arnold Press 3x6-12
* Overhead Tricep Extension 3x6-12
* Hanging Leg Raise 3x6-12

**Pull**
* Pullup 3x6-12
* Bent-over Row 3x6-12
* Reverse Fly 3x6-12
* Shrug 3x6-12
* Curl 3x6-12

**Legs**
* Goblet Squat 3x6-12
* Lunge 3x6-12
* Single-Lef Deadlift 3x6-12
* Calf Raise 3x6-12
""" + notes
    return Program("PPL Stopgap/4", workouts, exercises, tags, description)
}

func PPLStopgap6() -> Program {
    let workouts = [
        Workout("Push 1", ["Bench Press", "Incline Fly", "Arnold Press", "Overhead Tricep Extension", "Hanging Leg Raise"], scheduled: true, optional: []),
        Workout("Puull 1", ["Pullup", "Lunge", "Bent-over Row", "Reverse Fly", "Shrug", "Curl"], scheduled: true, optional: []),
        Workout("Legs 1", ["Goblet Squat", "Lunge", "Single-leg Deadlift", "Calf Raise", "Hanging Leg Raise"], scheduled: true, optional: []),

        Workout("Push 2", ["Bench Press", "Incline Fly", "Arnold Press", "Overhead Tricep Extension", "Hanging Leg Raise"], scheduled: true, optional: []),
        Workout("Pull 2", ["Pullup", "Lunge", "Bent-over Row", "Reverse Fly", "Shrug", "Curl", "Hanging Leg Raise"], scheduled: true, optional: []),
        Workout("Legs 2", ["Goblet Squat", "Lunge", "Single-leg Deadlift", "Calf Raise"], scheduled: true, optional: []),
    ]
    
    let tags: [Program.Tags] = [.beginner, .strength, .dumbbell, .unisex, .ageUnder40, .age50s]
    let description = """
Beginner strength [program](https://www.reddit.com/r/Fitness/comments/2e79y4/dumbbell_ppl_proposed_alternative_to_dumbbell) using only dumbbells. Note that you should have a bench and a pullup bar. Not quite as effective as the programs that use barbells (especially for the lower body) but way better than nothing.

**Push 1**
* Bench Press 3x6-12
* Incline Fly 3x6-12
* Arnold Press 3x6-12
* Overhead Tricep Extension 3x6-12
* Hanging Leg Raise 3x6-12

**Pull 1**
* Pullup 3x6-12
* Bent-over Row 3x6-12
* Reverse Fly 3x6-12
* Shrug 3x6-12
* Curl 3x6-12

**Legs 1**
* Goblet Squat 3x6-12
* Lunge 3x6-12
* Single-Lef Deadlift 3x6-12
* Calf Raise 3x6-12
* Hanging Leg Raise 3x6-12

**Push 2**
* Bench Press 3x6-12
* Incline Fly 3x6-12
* Arnold Press 3x6-12
* Overhead Tricep Extension 3x6-12

**Pull 2**
* Pullup 3x6-12
* Bent-over Row 3x6-12
* Reverse Fly 3x6-12
* Shrug 3x6-12
* Curl 3x6-12
* Hanging Leg Raise 3x6-12

**Legs 2**
* Goblet Squat 3x6-12
* Lunge 3x6-12
* Single-Lef Deadlift 3x6-12
* Calf Raise 3x6-12

""" + notes
    return Program("PPL Stopgap/6", workouts, exercises, tags, description)
}


