import Foundation

func Metallicadpa() -> Program {
    let warmup = Warmups(withBar: 1, firstPercent: 0.5, lastPercent: 0.9, reps: [10, 10, 5, 3])
    let noWarmup = Warmups(withBar: 0, firstPercent: 0.6, lastPercent: 0.9, reps: [])
    
    let exercises = [
        barbell("Deadlift",         "Deadlift",            1, amrap: 5, warmups: warmup, useBumpers: true, restMins: 3.0),
        barbell("Pendlay Row",      "Pendlay Row",         5, amrap: 5, warmups: warmup, restMins: 3.0),
        bodyWeight("Chinups",       "Chinup",              requestedReps: 15, targetReps: 36, restMins: 2.5),
        machine("Seated Cable Row", "Seated Cable Row",    3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Hammer Curls",    "Hammer Curls",        4, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Dumbbell Curls",  "Concentration Curls", 4, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),

        barbell("Bench Press",             "Bench Press",             5, amrap: 5, warmups: warmup, restMins: 3.0),
        barbell("OHP",                     "Overhead Press",          5, amrap: 5, warmups: warmup, restMins: 3.0),
        barbell("OHP 2",                   "Overhead Press",          3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        barbell("Bench Press 2",           "Bench Press",             3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Dumbbell Incline Press", "Dumbbell Incline Press",  3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        machine("Triceps Pushdown",        "Triceps Pushdown (rope)", 3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Lateral Raises 1",       "Side Lateral Raise",      3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Triceps Press",          "Seated Triceps Press",    3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Lateral Raises 2",       "Side Lateral Raise",      3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),

        barbell("Squat",             "Low bar Squat",        3, amrap: 5, warmups: warmup, restMins: 3.0),
        barbell("Romanian Deadlift", "Romanian Deadlift",    3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        pairedPlates("Leg Press",    "Leg Press",            3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        machine("Leg Curls",         "Seated Leg Curl",      3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        pairedPlates("Calf Raises",  "Standing Calf Raises", 3, minReps: 8, maxReps: 12, warmups: noWarmup, restMins: 2.0)]
    
    let workouts = [
        Workout("Pull (deadlift)", ["Deadlift", "Chinups", "Seated Cable Row", "Hammer Curls", "Dumbbell Curls"], scheduled: true, optional: []),
        Workout("Push (bench)", ["Bench Press", "OHP 2", "Dumbbell Incline Press", "Triceps Pushdown", "Lateral Raises 1", "Triceps Press", "Lateral Raises 2"], scheduled: true, optional: []),
        Workout("Legs (1)", ["Squat", "Romanian Deadlift", "Leg Press", "Leg Curls", "Calf Raises"], scheduled: true, optional: []),

        Workout("Pull (row)", ["Pendlay Row", "Chinups", "Seated Cable Row", "Hammer Curls", "Dumbbell Curls"], scheduled: true, optional: []),
        Workout("Push (ohp)", ["OHP", "Bench Press 2", "Dumbbell Incline Press", "Triceps Pushdown", "Lateral Raises 1", "Triceps Press", "Lateral Raises 2"], scheduled: true, optional: []),
        Workout("Legs (2)", ["Squat", "Romanian Deadlift", "Leg Press", "Leg Curls", "Calf Raises"], scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .barbell, .sixDays, .unisex, .ageUnder40]
    let description = """
Push/pull/legs workout for beginners by [Metallicadpa](https://www.reddit.com/r/Fitness/comments/37ylk5/a_linear_progression_based_ppl_program_for). The workouts are:

**Pull**
* Deadlift 1x5+/Pendlay Rows 4x5, 1x5+ (these alternate with each pull day)
* Chinups 3x8-12
* Seated Cable Row 3x8-12
* Hammer Curls 4x8-12
* Dumbbell Curls 4x8-12

**Push**
* Bench Press 4x5, 1x5+/OHP 4x5, 1x5+ (these alternate with each push day)
* OHP 3x8-12/Bench Press 3x8-12 (ditto)
* Incline Dumbbell Press 3x8-12
* Triceps Pushdowns 3x8-12
* Lateral Raises 3x15-20
* Overhead Triceps Extensions 3x8-12
* Lateral Raises 3x15-20

**Legs**
* Squat 2x5, 1x5+
* Romanian Deadlift 3x8-12
* Leg Press 3x8-12
* Leg Curls 3x8-12
* Calf Raises 5x8-12

**Notes**
* For squat, pendlay row, bench, and OHP it's recommended to increase weights by 5 pounds each workout. For deadlift 10 pounds.
* If you fail tp progress on a lift 3x in a row the app will do a deload by 10% for that lift.
* On the As Many Reps As Possible (AMRAP) sets (e.g. 1x5+) do as many reps as you can while maintaining good form.
* The program calls for one rest day each week; pick whatever day is convenient for you.
* For the push day you can superset the lateral raises with the triceps lifts.
* The URL above has a lot of suggestions for swapping out accessory exercises if you're missing equipment or just want to do something different.
"""
    return Program("Metallicadpa PPL", workouts, exercises, tags, description)
}


