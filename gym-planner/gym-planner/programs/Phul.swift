import Foundation

func Phul() -> Program {
    let warmup = Warmups(withBar: 1, firstPercent: 0.5, lastPercent: 0.9, reps: [10, 5, 3])
    let noWarmup = Warmups(withBar: 0, firstPercent: 0.6, lastPercent: 0.9, reps: [])
    
    let exercises = [
        barbell("Bench Press",     "Bench Press",            3, by: 5,  warmups: warmup, restMins: 2.0),
        dumbbell("Incline Press",  "Dumbbell Incline Press", 3, by: 10, warmups: noWarmup, restMins: 2.0),
        barbell("Pendlay Row",     "Pendlay Row",            3, by: 5,  warmups: noWarmup, restMins: 2.0),
        machine("Lat Pulldown",    "Lat Pulldown",           3, by: 10, warmups: noWarmup, restMins: 2.0),
        barbell("OHP",             "Overhead Press",         2, by: 8,  warmups: noWarmup, restMins: 2.0),
        barbell("Barbell Curl",    "Barbell Curl",           2, by: 10, warmups: noWarmup, restMins: 2.0),
        dumbbell("Skull Crushers", "Skull Crushers",         2, by: 10, warmups: noWarmup, restMins: 2.0),

        barbell("Squat",              "Low bar Squat",        3, by: 5, warmups: warmup, restMins: 3.0),
        barbell("Deadlift",           "Deadlift",             3, by: 5, warmups: warmup, useBumpers: true, restMins: 3.0),
        pairedPlates("Leg Press",     "Leg Press",            3, by: 15, warmups: noWarmup, restMins: 2.0),
        machine("Leg Curls 1",        "Seated Leg Curl",      3, by: 10, warmups: noWarmup, restMins: 2.0),
        pairedPlates("Calf Raises 1", "Standing Calf Raises", 4, by: 10, warmups: noWarmup, restMins: 2.0),

        barbell("Incline Bench",    "Incline Bench Press",     3, by: 12, warmups: warmup, restMins: 2.0),
        dumbbell("Dumbbell Flyes",  "Dumbbell Flyes",          3, by: 12, warmups: noWarmup, restMins: 2.0),
        machine("Seated Cable Row", "Seated Cable Row",        3, by: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Kroc Row",        "Kroc Row",                3, by: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Lateral Raises",  "Side Lateral Raise",      3, by: 12, warmups: noWarmup, restMins: 2.0),
        dumbbell("Incline Curl",    "Incline Dumbbell Curl",   3, by: 12, warmups: noWarmup, restMins: 2.0),
        machine("Triceps Pushdown", "Triceps Pushdown (rope)", 3, by: 12, warmups: noWarmup, restMins: 2.0),

        barbell("Front Squat",        "Front Squat",          3, by: 12, warmups: warmup, restMins: 3.0),
        barbell("Lunge",              "Barbell Lunge",        3, by: 12, warmups: noWarmup, restMins: 2.0),
        machine("Leg Extensions",     "Leg Extensions",       3, by: 15, warmups: noWarmup, restMins: 2.0),
        machine("Leg Curls 2",        "Seated Leg Curl",      3, by: 15, warmups: noWarmup, restMins: 2.0),
        pairedPlates("Calf Raises 2", "Standing Calf Raises", 3, by: 12, warmups: noWarmup, restMins: 2.0),
        machine("Calf Press",         "Calf Press",           3, by: 12, warmups: noWarmup, restMins: 2.0)]
    
    let workouts = [
        Workout("Upper Power", ["Bench Press", "Incline Press", "Pendlay Row", "Lat Pulldown", "OHP", "Barbell Curl", "Skull Crushers"], scheduled: true, optional: []),
        Workout("Lower Power", ["Squat", "Deadlift", "Leg Curls 1", "Calf Raises 1"], scheduled: true, optional: []),
        Workout("Upper Hypertrophy", ["Incline Bench", "Dumbbell Flyes", "Seated Cable Row", "Kroc Row", "Lateral Raises", "Incline Curl", "Triceps Pushdown"], scheduled: true, optional: []),
        
        Workout("Lower Hypertrophy", ["Front Squat", "Lunge", "Leg Extensions", "Leg Curls 2", "Calf Raises 2", "Calf Press"], scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.intermediate, .hypertrophy, .barbell, .fourDays, .unisex, .ageUnder40]
    let description = """
[Power Hypertrophy Upper Lower](https://www.muscleandstrength.com/workouts/phul-workout) workout. Workouts should take 45-60 minutes. The workouts are:

**Upper Power**
* Bench Press 3x5
* Incline Dumbbell Bench 3x10
* Pendlay Row 3x5
* Lat Pulldown 3x10
* OHP 2x8
* Barbell Curl 2x10
* Skullcrusher 2x10

**Lower Power**
* Squat 3x5
* Deadlift 3x5
* Leg Press 3x15
* Leg Curl 3x10
* Calf Raise 4x10

**Upper Hypertrophy**
* Incline Bench 3x12
* Dumbbell Flye 3x12
* Seated Cable Row 3x12
* Kroc Row 3x12
* Lateral Raise 3x12
* Incline Dumbbell Curl 3x12
* Triceps Pushdown 3x12

**Lower Hypertrophy**
* Front Squat 3x12
* Barbell Lunge 3x12
* Leg Extension 3x15
* Leg Curl 3x15
* Calf Raise 3x12
* Calf Press 3x12

**Notes**
* After you become accustomed to the workload it's suggested that you add more volume by adding an extra set (and possibly dropping reps).
* Don't do the lifts to failure: try and leave one rep in the tank.
* Ab work can be added to the end of workouts or done on off days.
"""
    return Program("PHUL", workouts, exercises, tags, description)
}


