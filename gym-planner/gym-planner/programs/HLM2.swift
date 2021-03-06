/// Masters program with cycles of 3x5, 3x3,and 3x1.
import Foundation

typealias Cycle = BaseCyclicPlan.Cycle

func HLM2() -> Program {
    let normalSquatWarmup = Warmups(withBar: 3, firstPercent: 0.5, lastPercent: 0.9, reps: [5, 3, 1, 1, 1])
    let lightSquatWarmup = Warmups(withBar: 3, firstPercent: 0.5, lastPercent: 0.9, reps: [5, 3, 1, 1])

    let normalWarmup = Warmups(withBar: 2, firstPercent: 0.5, lastPercent: 0.9, reps: [5, 3, 1, 1, 1])
    let latWarmup = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [5])
    let noWarmup = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let exercises = [
        barbell("OHP5",         "Overhead Press", 3, by: 5, warmups: normalWarmup, magnets: [1.25], restMins: 3.0),
        barbell("Squat5",       "Low bar Squat",  3, by: 5, warmups: normalWarmup, restMins: 4.0),
        barbell("Bench5",       "Bench Press",    3, by: 5, warmups: normalWarmup, restMins: 3.0),

        barbell("OHP3",         "Overhead Press", 3, by: 3, warmups: normalWarmup, magnets: [1.25], restMins: 3.0, afterExercise: "OHP5"),
        barbell("Squat3",       "Low bar Squat",  3, by: 3, warmups: normalWarmup, restMins: 4.0, afterExercise: "Squat5"),
        barbell("Bench3",       "Bench Press",    3, by: 3, warmups: normalWarmup, restMins: 3.0, afterExercise: "Bench5"),

        barbell("Squat1",       "Low bar Squat",  3, by: 1, warmups: normalWarmup, restMins: 4.0, afterExercise: "Squat3"),
        barbell("Bench1",       "Bench Press",    3, by: 1, warmups: normalWarmup, restMins: 3.0, afterExercise: "Bench3"),
        
        barbell("Light Squat",  "Low bar Squat",  1, by: 5, percent: 0.88, of: "Squat5", warmups: lightSquatWarmup, restMins: 2.0),

        barbell("Medium Squat", "Low bar Squat",  2, by: 5, percent: 0.94, of: "Squat5", warmups: normalSquatWarmup, restMins: 3.0),
        barbell("Medium Bench", "Bench Press",    2, by: 5, percent: 0.94, of: "Bench5", warmups: normalWarmup, restMins: 3.0),

        barbell("Deadlift",               "Deadlift",       1, by: 5, warmups: normalWarmup, useBumpers: true, restMins: 3.5),

        bodyWeight("Chinups",             "Chinup",         requestedReps: 12, targetReps: 30,   restMins: 2.5),
        machine("Lat Pulldown",           "Lat Pulldown",   3, minReps: 4, maxReps: 8, warmups: latWarmup, restMins: 2.5),
        singleDumbbell("Back Extensions", "Back Extension", 3, minReps: 6, maxReps: 12, restMins: 2.0),
        dumbbell("Dumbbell Flyes",        "Dumbbell Flyes", 3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 2.0),
        barbell("Static Hold",            "Static Hold",    3, by: 1, warmups: nil, restMins: 3.0),

        bodyWeight("Kneeling Front Plank",  "Front Plank",           1, minSecs: 30, maxSecs: 60),
        bodyWeight("Front Plank",           "Front Plank",           1, minSecs: 30, maxSecs: 60),
        bodyWeight("Side Plank",            "Side Plank",            2, minSecs: 15, maxSecs: 30),
        bodyWeight("Leg Lift Plank",        "Leg Lift Plank",        2, minSecs: 15, maxSecs: 30),
        bodyWeight("Arm & Leg Lift Front Plank", "Arm & Leg Lift Front Plank", 2, minSecs: 15, maxSecs: 30),
        bodyWeight("Decline Plank",         "Decline Plank",         1, minSecs: 30, maxSecs: 60),
        bodyWeight("Decline & March Plank", "Decline & March Plank", 1, minSecs: 30, maxSecs: 60),
        bodyWeight("Wall Plank",            "Wall Plank",            1, minSecs: 30, maxSecs: 60),
        bodyWeight("Wall March Plank",      "Wall March Plank",      1, minSecs: 30, maxSecs: 60),
        bodyWeight("Dragon Flag",           "Dragon Flag",           3, minReps: 1, maxReps: 8, restMins: 1.5),
        bodyWeight("Hanging Dragon Flag",   "Hanging Dragon Flag",   1, minSecs: 5, maxSecs: 20),

//        bodyWeight("Foam Rolling",            "IT-Band Foam Roll",         1, by: 15, restMins: 0.0),
//        bodyWeight("Shoulder Dislocates",     "Shoulder Dislocate",        1, by: 12, restMins: 0.0),
//        bodyWeight("Bent-knee Iron Cross",    "Bent-knee Iron Cross",      1, by: 10, restMins: 0.0),
//        bodyWeight("Roll-over into V-sit",    "Roll-over into V-sit",      1, by: 15, restMins: 0.0),
//        bodyWeight("Rocking Frog Stretch",    "Rocking Frog Stretch",      1, by: 10, restMins: 0.0),
//        bodyWeight("Fire Hydrant Hip Circle", "Fire Hydrant Hip Circle",   1, by: 10, restMins: 0.0),
//        bodyWeight("Mountain Climber",        "Mountain Climber",          1, by: 10, restMins: 0.0),
//        bodyWeight("Cossack Squat",           "Cossack Squat",             1, by: 10, restMins: 0.0),
//        bodyWeight("Piriformis Stretch",      "Seated Piriformis Stretch", 2, secs: 30),
//        bodyWeight("Hip Flexor Stretch",      "Rear-foot-elevated Hip Flexor Stretch", 2, secs: 30)
    ]
    makeProgression(exercises, "Kneeling Front Plank", "Front Plank", "Side Plank", "Leg Lift Plank", "Arm & Leg Lift Front Plank", "Decline Plank", "Decline & March Plank", "Wall Plank", "Wall March Plank", "Dragon Flag", "Hanging Dragon Flag")

    let workouts = [
        Workout("Light5", ["OHP5", "Light Squat", "Chinups", "Lat Pulldown", "Side Plank", "Static Hold"], scheduled: true, optional: ["Chinups", "Lat Pulldown", "Side Plank", "Static Hold"]),
        Workout("Light3", ["OHP3", "Light Squat", "Chinups", "Lat Pulldown", "Side Plank", "Static Hold"], scheduled: true, optional: ["Chinups", "Lat Pulldown", "Side Plank", "Static Hold"]),

        Workout("Medium", ["Medium Bench", "Medium Squat", "Chinups", "Lat Pulldown", "Dumbbell Flyes", "Leg Lift Plank"], scheduled: true, optional: ["Dumbbell Flyes", "Chinups", "Lat Pulldown", "Leg Lift Plank"]),

        Workout("Heavy5", ["Squat5", "Bench5", "Deadlift", "Back Extensions"], scheduled: true, optional: ["Back Extensions"]),
        Workout("Heavy3", ["Squat3", "Bench3", "Deadlift", "Back Extensions"], scheduled: true, optional: ["Back Extensions"]),
        Workout("Heavy1", ["Squat1", "Bench1", "Deadlift", "Back Extensions"], scheduled: true, optional: ["Back Extensions"]),
//      Workout("Mobility", ["Foam Rolling", "Shoulder Dislocates", "Bent-knee Iron Cross", "Roll-over into V-sit", "Rocking Frog Stretch", "Fire Hydrant Hip Circle", "Mountain Climber", "Cossack Squat", "Piriformis Stretch", "Hip Flexor Stretch"], scheduled: false),
        ]

    let tags: [Program.Tags] = [.advanced, .strength, .barbell, .unisex, .threeDays, .age40s, .age50s]
    let description = """
This is the program I use and is based on the HLM program from the book _The Barbell Prescription: Strength Training for Life After 40_ with the addition of mobility and cardio workouts. It uses a very gradual progression and the heavy day cycles between sets of 5, 3, and 1 reps with the weight increasing each time the reps go down. It's a three day a week program and the days look like this:

**Heavy**
* Squat 3x5,3,1   reps change each week
* Bench 3x5,3,1
* Deadlift 1x5,3,1

It should be a bit of a struggle to do all the reps.

**Medium**
* Squat 2x5 at 94% of heavy's 5 rep weight
* Bench 2x5 at 94% of heavy's 5 rep weight
* Chins up to 30 reps

These should feel like you are working hard without being in danger of missing a rep and with some energy left after each set.

**Light**
* Squat 1x5 at 88% of heavy's 5 rep weight
* OHP 3x5,3
* Chins up to 30 reps

All the reps should be fairly easy.

**Notes**
* Start with the Heavy5 workout.
* Each week do a heavy, medium, and light workout cycling through the heavy and light workouts with different rep ranges.
* Chinups are done with as many sets as are required, once you can do thirty add weight.
* If you get stuck at a rep range keep trying to advance on the other rep ranges (that will help you progress on the other rep range).
* Note that the app will ensure that the weights for a higher rep range are higher than those for the next lower rep range.
"""
    return Program("HLM2", workouts, exercises, tags, description)
}
