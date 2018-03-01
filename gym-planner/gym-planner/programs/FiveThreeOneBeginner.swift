/// Three week cycle betwen 5+ reps, 3+ reps, and 1+ reps.
import Foundation

func FiveThreeOneBeginner() -> Program {
    func planTimedMob(_ numSets: Int, targetTime: Int? = nil) -> Plan {
        return TimedPlan("\(numSets) timed sets", numSets: numSets, targetTime: targetTime)
    }
    
    let exercises = [
        bodyWeight("Box Jumps",          "Box Jump",           1, minReps: 10, maxReps: 15, restMins: 0.0),
        bodyWeight("Medicine Ball Slam", "Medicine Ball Slam", 1, minReps: 10, maxReps: 15, restMins: 0.0),

        barbell531Beginner("Squat",          "Low bar Squat",  restMins: 2.0),
        barbell531Beginner("Deadlift",       "Deadlift",       useBumpers: true, restMins: 2.0),
        barbell531Beginner("Bench Press",    "Bench Press",    magnets: [1.25], restMins: 1.5),
        barbell531Beginner("Overhead Press", "Overhead Press", magnets: [1.25], restMins: 1.5),
        
        // single leg/core
        bodyWeight("Ab Wheel Rollout (core)",       "Ab Wheel Rollout",       requestedReps: 50, targetReps: 100, restMins: 1.0),
        bodyWeight("Back Extension (core)",         "Back Extension",         requestedReps: 50, targetReps: 100, restMins: 1.0),
        machine("Cable Crunch (core)",              "Cable Crunch",           5, minReps: 10, maxReps: 15, restMins: 1.5),
        bodyWeight("Reverse Hyperextension (core)", "Reverse Hyperextension", requestedReps: 50, targetReps: 100, restMins: 1.0),
        bodyWeight("Hanging Leg Raise (core)",      "Hanging Leg Raise",      requestedReps: 50, targetReps: 100, restMins: 1.0),
        dumbbell("Spell Caster (core)",             "Spell Caster",           5, minReps: 10, maxReps: 15, restMins: 1.0),
        
        dumbbell("Dumbbell Lunge (leg)",        "Dumbbell Lunge",    5, minReps: 10, maxReps: 15, restMins: 1.0),
        bodyWeight("Kettlebell Snatch (leg)",    "One-Arm Kettlebell Snatch", 5, minReps: 10, maxReps: 15, restMins: 1.0),
        bodyWeight("Kettlebell Swing (leg)",     "Kettlebell Two Arm Swing", 5, minReps: 10, maxReps: 15, restMins: 1.0),
        dumbbell("Step-ups (leg)",              "Step-ups",          5, minReps: 10, maxReps: 15, restMins: 1.0),

        // pull
        bodyWeight("Chinup (pull)",       "Chinup",       requestedReps: 50, targetReps: 100, restMins: 1.0),
        machine("Face Pull (pull)",       "Face Pull",    5, minReps: 10, maxReps: 15, restMins: 1.0),
        dumbbell("Hammer Curls (pull)",   "Hammer Curls", 5, minReps: 10, maxReps: 15, restMins: 1.0),
        bodyWeight("Inverted Row (pull)", "Inverted Row", requestedReps: 50, targetReps: 100, restMins: 1.0),
        machine("Lat Pulldown (pull)",    "Lat Pulldown", 5, minReps: 10, maxReps: 15, restMins: 1.5),
        barbell("Pendlay Row (pull)",     "Pendlay Row",  5, minReps: 10, maxReps: 15, restMins: 1.5),
        
        // push
        bodyWeight("Dips (push)",               "Dips",                    requestedReps: 50, targetReps: 100, restMins: 1.0),
        dumbbell("Dumbbell Bench Press (push)", "Dumbbell Bench Press",    5, minReps: 10, maxReps: 15, restMins: 1.0),
        bodyWeight("Push Ups (push)",           "Pushup",                  requestedReps: 50, targetReps: 100, restMins: 1.0),
        singleDumbbell("Triceps Press (push)",  "Seated Triceps Press",    5, minReps: 10, maxReps: 15, restMins: 1.0),
        machine("Triceps Pushdown (push)",      "Triceps Pushdown (rope)", 5, minReps: 10, maxReps: 15, restMins: 1.5),

        bodyWeight("Foam Rolling",            "IT-Band Foam Roll",         1, by: 15, restMins: 0.0),
        bodyWeight("Shoulder Dislocates",     "Shoulder Dislocate",        1, by: 12, restMins: 0.0),
        bodyWeight("Bent-knee Iron Cross",    "Bent-knee Iron Cross",      1, by: 10, restMins: 0.0),
        bodyWeight("Roll-over into V-sit",    "Roll-over into V-sit",      1, by: 15, restMins: 0.0),
        bodyWeight("Rocking Frog Stretch",    "Rocking Frog Stretch",      1, by: 10, restMins: 0.0),
        bodyWeight("Fire Hydrant Hip Circle", "Fire Hydrant Hip Circle",   1, by: 10, restMins: 0.0),
        bodyWeight("Mountain Climber",        "Mountain Climber",          1, by: 10, restMins: 0.0),
        bodyWeight("Cossack Squat",           "Cossack Squat",             1, by: 10, restMins: 0.0),
        bodyWeight("Piriformis Stretch",      "Seated Piriformis Stretch", 2, secs: 30),
        bodyWeight("Hip Flexor Stretch",      "Rear-foot-elevated Hip Flexor Stretch", 2, secs: 30)]
    
    // Aux exercises default to Hanging Leg Raise, Lat Pulldown, and Triceps Pushdown.
    let core = ["Ab Wheel Rollout (core)", "Back Extension (core)", "Cable Crunch (core)", "Hanging Leg Raise (core)", "Reverse Hyperextension (core)", "Spell Caster (core)"]
    let leg = ["Dumbbell Lunge (leg)", "Kettlebell Snatch (leg)", "Kettlebell Swing (leg)", "Step-ups (leg)"]
    let pull = ["Chinup (pull)", "Face Pull (pull)", "Hammer Curls (pull)", "Inverted Row (pull)", "Lat Pulldown (pull)", "Pendlay Row (pull)"]
    let push = ["Dips (push)", "Dumbbell Bench Press (push)", "Push Ups (push)", "Triceps Press (push)", "Triceps Pushdown (push)"]
    let aux = core + leg + pull + push
    let optional = ["Ab Wheel Rollout (core)", "Back Extension (core)", "Cable Crunch (core)", "Chinup (pull)", "Dips (push)", "Dumbbell Bench Press (push)", "Dumbbell Lunge (leg)", "Face Pull (pull)", "Hammer Curls (pull)", "Inverted Row (pull)", "Kettlebell Snatch (leg)", "Kettlebell Swing (leg)", "Medicine Ball Slam", "Pendlay Row (pull)", "Push Ups (push)", "Reverse Hyperextension (core)", "Spell Caster (core)", "Step-ups (leg)", "Triceps Press (push)"]
    
    let workouts = [
        Workout("Squat",    ["Box Jumps", "Medicine Ball Slam", "Squat",       "Bench Press"] + aux,    scheduled: true, optional: optional),
        Workout("Deadlift", ["Box Jumps", "Medicine Ball Slam", "Deadlift",    "Overhead Press"] + aux, scheduled: true, optional: optional),
        Workout("Bench",    ["Box Jumps", "Medicine Ball Slam", "Bench Press", "Squat"] + aux,          scheduled: true, optional: optional),
        Workout("Mobility", ["Foam Rolling", "Shoulder Dislocates", "Bent-knee Iron Cross", "Roll-over into V-sit", "Rocking Frog Stretch", "Fire Hydrant Hip Circle", "Mountain Climber", "Cossack Squat", "Piriformis Stretch", "Hip Flexor Stretch"], scheduled: false)]
    
    let tags: [Program.Tags] = [.beginner, .strength, .barbell, .threeDays, .unisex, .ageUnder40, .age40s, .age50s]
    let description = """
This [program](https://www.reddit.com/r/Fitness/wiki/531-beginners) is a variant of Jim Wendler's popular 531 program designed for beginners. It uses a three week cycle with 5+, 3+, and 1+ reps within each cycle and higher weights as the reps drop. Once the cycle finishes you have the option of adding weight, deloading, or keeping the weights the same. Progression is slower with this program than most of the other beginner programs but it's also a program than you can run for longer than the other programs. It's a three day a week program and the days look like this:

**Squat**
* Squat 5,3,1   reps change each week
* Bench 5,3,1
* Hanging Leg Raise 50 reps
* Lat Pulldown 4x12
* Triceps Pushdown 4x12

**Deadlift**
* Deadlift 5,3,1   reps change each week
* Overhead Press 5,3,1
* Hanging Leg Raise 50 reps
* Lat Pulldown 4x12
* Triceps Pushdown 4x12

**Bench**
* Bench 5,3,1   reps change each week
* Squat 5,3,1
* Hanging Leg Raise 50 reps
* Lat Pulldown 4x12
* Triceps Pushdown 4x12

**Notes**
* Warmup with either Box Squats or Medicine Ball Slams (use the Options button in the workout screen to switch in slams).
* The main lifts ascend to either 5+, 3+, or 1+ reps and then have a back off set.
* For the N+ sets do as many reps as you can but stop when the bar either starts to slow significantly or your form starts to break down.
* For the upper body main lifts you'll need 1.25 pound plates or magnets.
* In each workout you should perform three assistence exercises: one each from leg/core, pull, and push. Do 50-100 reps of each of these. If you can't do 50 reps of an exercise you can use the Options button in the Workout screen to enable a second exercise from within that category and spread the reps out between the two exercises. (You can also use the Options button to switch which accessories you want to do).
* Wendler recommends performing the mobility exercises before each workout as well as on the off days. The original recomendation was for [Agile 8](https://www.t-nation.com/training/defranco-agile-8) but this version uses [Limber 11](https://www.bodybuilding.com/fun/limber-11-the-only-lower-body-warm-up-youll-ever-need.html) which is the updated version from DeFranco.
* Wendler recommends cardio work to be performed three days a week between lifting days.
* It's recommended than you do a deload after completing five full cycles (the deload menu item will be bolded after five full cycles).
* You can also do a deload if you missed a rep within the cycle but normally you should only do so if it's a persistent problem and not something like one night of bad sleep.
"""
    return Program("531 Beginner", workouts, exercises, tags, description)
}

