import Foundation

func Stopgap() -> Program {
    let noWarmup = Warmups(withBar: 0, firstPercent: 0.6, lastPercent: 0.9, reps: [])
    
    let exercises = [
        // A
        dumbbell("Bulgarian Split Squat",    "Dumbbell Single Leg Split Squat", 3, minReps: 5, maxReps: 10, warmups: noWarmup, restMins: 1.0),
        dumbbell("Floor Press",              "Dumbbell Floor Press",            3, minReps: 5, maxReps: 10, warmups: noWarmup, restMins: 1.0),
        dumbbell("Straight-legged Deadlift", "Dumbbell Romanian Deadlift",      3, minReps: 5, maxReps: 10, warmups: noWarmup, restMins: 1.0),
        bodyWeight("Plank",                  "Front Plank",                     3, minSecs: 20, maxSecs: 120),
        bodyWeight("Dips",                   "Dips",                            3, minReps: 5, maxReps: 10, restMins: 1.0),
        bodyWeight("Chinups",                "Chinup",                          requestedReps: 3, targetReps: 30, restMins: 1.0),
        dumbbell("Lunge",                    "Dumbbell Lunge",                  3, minReps: 5, maxReps: 10, warmups: noWarmup, restMins: 1.0),

        // B
        dumbbell("Seated OHP", "Dumbbell Seated Shoulder Press", 3, minReps: 5, maxReps: 10, warmups: noWarmup, restMins: 1.0),
        dumbbell("Row",        "Bent Over Dumbbell Row",         3, minReps: 5, maxReps: 10, warmups: noWarmup, restMins: 1.0),
]
    
    let workouts = [
        Workout("A", ["Bulgarian Split Squat", "Lunge", "Floor Press", "Straight-legged Deadlift", "Chinups", "Plank", "Dips"], scheduled: true, optional: ["Dips", "Chinups", "Lunge"]),
        Workout("B", ["Bulgarian Split Squat", "Lunge", "Seated OHP", "Row", "Chinups", "Plank", "Dips"], scheduled: true, optional: ["Dips", "Chinups", "Lunge"])]
    
    let tags: [Program.Tags] = [.beginner, .strength, .dumbbell, .threeDays, .unisex, .ageUnder40, .age50s]
    let description = """
Beginner strength [program](https://www.reddit.com/r/Fitness/comments/zc0uy/a_beginner_dumbbell_program_the_dumbbell_stopgap/) using only dumbbells. Not quite as effective as the programs that use barbells (especially for the lower body) but way better than nothing. The workouts alternate between the A and B workouts and there should be rest day(s) between workouts.

**A**
* Bulgarian Split Squat 3x5-10
* Floor Press 3x5-10
* Straight-legged Deadlift 3x5-10
* Plank 3x20-60

**B**
* Bulgarian Split Squat 3x5-10
* Seated OHP 3x5-10
* Row 3x5-10
* Plank 3x20-120

**Notes**
* Start with the lightest weights you have available.
* If you have the equipment dips and chinups are recommended.
"""
    return Program("Dumbbell Stopgap", workouts, exercises, tags, description)
}


