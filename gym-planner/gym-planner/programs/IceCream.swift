import Foundation

func IceCream() -> Program {
    let warmup = Warmups(withBar: 2, firstPercent: 0.6, lastPercent: 0.9, reps: [5, 5, 3])
    let rowWarmup = Warmups(withBar: 0, firstPercent: 0.75, lastPercent: 0.85, reps: [5, 3])
    let noWarmup = Warmups(withBar: 0, firstPercent: 0.6, lastPercent: 0.9, reps: [])
    
    let exercises = [
        barbell("Squat",              "Low bar Squat",  5, by: 5, warmups: warmup, restMins: 3.0),
        barbell("Bench Press",        "Bench Press",    5, by: 5, warmups: warmup, restMins: 3.0),
        barbell("Bent Over Row",      "Pendlay Row",    5, by: 5, warmups: rowWarmup, restMins: 2.0),
        barbell("Barbell Shrugs",     "Barbell Shrug",  3, by: 8, warmups: noWarmup, restMins: 2.0),
        dumbbell("Tricep Extensions", "Skull Crushers", 3, by: 8, warmups: noWarmup, restMins: 2.0),
        barbell("Barbell Curls",      "Barbell Curl",   3, by: 8, warmups: noWarmup, restMins: 2.0),
        dumbbell("Back Extensions",   "Back Extension", 2, by: 10, warmups: noWarmup, restMins: 2.0),
        machine("Cable Crunches",     "Cable Crunch",   3, by: 10, warmups: noWarmup, restMins: 2.0),
        bodyWeight("Chinups",         "Chinup",         requestedReps: 15, targetReps: 30, restMins: 2.5),

        barbell("Deadlift",         "Deadlift",               1, by: 5, warmups: warmup, useBumpers: true, restMins: 3.0),
        barbell("OHP",              "Overhead Press",         5, by: 5, warmups: warmup, restMins: 3.0),
        barbell("Light Row",        "Pendlay Row",            5, by: 5, percent: 0.9, of: "Bent Over Row", warmups: rowWarmup, restMins: 2.0),
        barbell("Close-Grip Bench", "Close-Grip Bench Press", 3, by: 8, warmups: warmup, restMins: 3.0),
        barbell("Barbell Curls",    "Barbell Curl",           3, by: 8, warmups: noWarmup, restMins: 2.0),
        machine("Cable Crunches",   "Cable Crunch",           3, by: 10, warmups: noWarmup, restMins: 2.0)]
    
    let workouts = [
        Workout("A", ["Squat", "Bench Press", "Bent Over Row", "Barbell Shrugs", "Tricep Extensions", "Barbell Curls", "Back Extensions", "Cable Crunches", "Chinups"], scheduled: true, optional: ["Chinups"]),
        Workout("B", ["Squat", "Deadlift", "OHP", "Light Row", "Close-Grip Bench", "Barbell Curls", "Cable Crunches"], scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .strength, .barbell, .threeDays, .unisex, .ageUnder40, .age40s]
    let description = """
This is a standard linear progression program that includes more accessories than most beginner programs. The [program](https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout) is by Jason Blaha is three days a week and should take about ninety minutes to complete. Cardio is optional and Jason recommends running the program for 12 weeks and then transitioning to an intermediate program. The A and B workouts alternate and, if you can do five chinups in a set, then you can use the options screen in the A workout to replace curls with chinups. If you're cutting Jason recommends dropping the primary lifts from 5x5 to 3x5 and the accessory lifts from 3x8 to 2x8. The workouts are:

**A**
* Squat 5x5
* Bench Press 5x5
* Bent Over Row 5x5
* Barbell Shrugs 3x8
* Tricep Extensions 3x8
* Barbell Curls 3x8
* Back Extensions 2x10
* Cable Crunches 3x10

**B**
* Squat 5x5
* Deadlift 1x5
* OHP 5x5
* Bent Over Row 5x5 (90% of workout A)
* Close-grip Bench Press 3x8
* Barbell Curls 3x8
* Cable Crunches 3x10
"""
    return Program("Ice Cream Fitness", workouts, exercises, tags, description, maxWorkouts: 3*12, nextProgram: "Phraks")   // TODO: use a real intermediate program
}


