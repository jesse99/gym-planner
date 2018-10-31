/// Masters program with cycles of 3x5, 3x3,and 3x1.
import Foundation

func HLM3() -> Program {
    // TODO: dumbbellWarmup should be doing two warmups at 50%
    let dumbbellWarmup = Warmups(withBar: 0, firstPercent: 0.5, lastPercent: 0.9, reps: [5, 3, 1])
    let deadWarmup = Warmups(withBar: 2, firstPercent: 0.5, lastPercent: 0.9, reps: [5, 3, 1])
    let noWarmup = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let exercises = [
        // Heavy
        dumbbell("Dumbbell Bench", "Dumbbell Bench Press", 3, minReps: 5, maxReps: 10, warmups: dumbbellWarmup, restMins: 4.0),
        dumbbell("Split Squat",    "Dumbbell Single Leg Split Squat", 3, minReps: 4, maxReps: 8, warmups: dumbbellWarmup, restMins: 3.5),
        dumbbell("Dumbbell Flyes", "Dumbbell Flyes", 3, minReps: 5, maxReps: 10, warmups: noWarmup, restMins: 3.0),
        barbell("Deadlift",        "Deadlift", 1, by: 5, warmups: deadWarmup, useBumpers: true, restMins: 3.5),

        // Light
        dumbbell("Dumbbell OHP",   "Dumbbell Shoulder Press", 3, minReps: 5, maxReps: 10, warmups: dumbbellWarmup, restMins: 3.5),
        bodyWeight("Chinups",      "Chinup", requestedReps: 12, targetReps: 30, restMins: 3.5),
        dumbbell("Farmer's Walk",  "Farmer's Walk", 2, by: 1, warmups: noWarmup, restMins: 3.0),
        barbell("Static Hold",     "Static Hold", 3, by: 1, warmups: nil, restMins: 3.0),
        singleDumbbell("Back Extension", "Back Extension", 3, minReps: 6, maxReps: 12, warmups: noWarmup, restMins: 3.0),

        // Medium
        bodyWeight("Dips",      "Dips", requestedReps: 12, targetReps: 30, restMins: 3.5),

        // Dumbbell Bench
        // Split Squat
        // Chinups

        bodyWeight("Foam Rolling",            "IT-Band Foam Roll",         1, by: 15, restMins: 0.0),
        bodyWeight("Shoulder Dislocates",     "Shoulder Dislocate",        1, by: 12, restMins: 0.0),
        bodyWeight("Bent-knee Iron Cross",    "Bent-knee Iron Cross",      1, by: 10, restMins: 0.0),
        bodyWeight("Roll-over into V-sit",    "Roll-over into V-sit",      1, by: 15, restMins: 0.0),
        bodyWeight("Rocking Frog Stretch",    "Rocking Frog Stretch",      1, by: 10, restMins: 0.0),
        bodyWeight("Fire Hydrant Hip Circle", "Fire Hydrant Hip Circle",   1, by: 10, restMins: 0.0),
        bodyWeight("Mountain Climber",        "Mountain Climber",          1, by: 10, restMins: 0.0),
        bodyWeight("Cossack Squat",           "Cossack Squat",             1, by: 10, restMins: 0.0),
        bodyWeight("Piriformis Stretch",      "Seated Piriformis Stretch", 2, secs: 30),
        bodyWeight("Hip Flexor Stretch",      "Rear-foot-elevated Hip Flexor Stretch", 2, secs: 30)
    ]
    
    let workouts = [
        Workout("Light", ["Dumbbell OHP", "Back Extension", "Chinups", "Farmer's Walk", "Static Hold"], scheduled: true, optional: ["Static Hold", "Back Extension"]),
        Workout("Medium", ["Dumbbell Bench", "Split Squat", "Chinups", "Dips", "Farmer's Walk", "Static Hold"], scheduled: true, optional: ["Static Hold", "Dips"]),
        Workout("Heavy", ["Dumbbell Bench", "Split Squat", "Deadlift", "Dumbbell Flyes"], scheduled: true),
        
        Workout("Mobility", ["Foam Rolling", "Shoulder Dislocates", "Bent-knee Iron Cross", "Roll-over into V-sit", "Rocking Frog Stretch", "Fire Hydrant Hip Circle", "Mountain Climber", "Cossack Squat", "Piriformis Stretch", "Hip Flexor Stretch"], scheduled: false),
    ]
    
    let tags: [Program.Tags] = [.intermediate, .strength, .barbell, .unisex, .threeDays, .age40s, .age50s]
    let description = """
This is one of the programs I use when I have intermittent access to a gym with barbells. It's a three day a week program and the days look like this:

**Heavy**
* Dumbbell Bench 3x4-12
* Bulgarian Split Squat 3x3-8
* Dumbbell Flyes 3x4-12
* Deadlift 1x5

**Light**
* Dumbbell OHP 3x4-12
* Chin Ups to 30 reps
* Farmers Walk x1

**Medium**
* Dumbbell Bench 3x4-12
* Bulgarian Split Squat 3x3-8
* Chin Ups to 30 reps

It should be a bit of a struggle to do all the reps.

**Notes**
* Chinups are done with as many sets as are required, once you can do thirty add weight.
* If you get stuck at a rep range keep trying to advance on the other rep ranges (that will help you progress on the other rep range).
"""
    return Program("HLM3", workouts, exercises, tags, description)
}
