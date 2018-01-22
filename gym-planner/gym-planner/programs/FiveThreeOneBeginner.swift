/// Three week cycle betwen 5+ reps, 3+ reps, and 1+ reps.
import Foundation

func FiveThreeOneBeginner() -> Program {
    func planBoxJump() -> Plan {
        let numSets = 1
        let minReps = 10
        let maxReps = 15
        return VariableRepsPlan("\(numSets)x\(minReps)-\(maxReps)", numSets: numSets, minReps: minReps, maxReps: maxReps)
    }
    
    func planMain() -> Plan {
        return FiveThreeOneBeginnerPlan("531", withBar: 2)
    }
    
    func planBodyAux() -> Plan {
        let targetReps = 100
        return VariableSetsPlan("\(targetReps) target", targetReps: targetReps)
    }
    
    func planWeightedAux() -> Plan {
        let numSets = 5
        let minReps = 10
        let maxReps = 15
        let warmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
        return CycleRepsPlan("\(numSets)x\(minReps)-\(maxReps)", warmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
    }
    
    func planTimedMob(_ numSets: Int, targetTime: Int? = nil) -> Plan {
        return TimedPlan("\(numSets) timed sets", numSets: numSets, targetTime: targetTime)
    }
    
    func planFixedMob(_ numSets: Int, _ numReps: Int) -> Plan {
        return FixedSetsPlan("\(numSets)x\(numReps)", numSets: numSets, numReps: numReps)
    }
    
    let exercises = [
        createVarReps("Box Jumps",          "Box Jump",           planBoxJump(), restMins: 0.0, requestedReps: 10),
        createVarReps("Medicine Ball Slam", "Medicine Ball Slam", planBoxJump(), restMins: 0.0, requestedReps: 10),

        createBarBell("Squat",          "Low bar Squat",  planMain(),  restMins: 2.0),
        createBarBell("Deadlift",       "Deadlift",       planMain(),  restMins: 2.0, useBumpers: true),
        createBarBell("Bench Press",    "Bench Press",    planMain(),  restMins: 1.5, magnets: [1.25]),
        createBarBell("Overhead Press", "Overhead Press", planMain(),  restMins: 1.5, magnets: [1.25]),
        
        // single leg/core
        createVarSets("Ab Wheel Rollout (core)",       "Ab Wheel Rollout",  planBodyAux(), restMins: 1.0, requestedReps: 50),
        createVarSets("Back Extension (core)",         "Back Extension",    planBodyAux(), restMins: 1.0, requestedReps: 50),
        createMachine("Cable Crunch (core)",           "Cable Crunch",      planWeightedAux(), restMins: 1.5),
        createVarSets("Reverse Hyperextension (core)", "Reverse Hyperextension", planBodyAux(), restMins: 1.0, requestedReps: 50),
        createVarSets("Hanging Leg Raise (core)",      "Hanging Leg Raise", planBodyAux(), restMins: 1.0, requestedReps: 50),
        createDumbbell2("Spell Caster (core)",         "Spell Caster",      planWeightedAux(), restMins: 1.0),
        
        createDumbbell2("Dumbbell Lunge (leg)",        "Dumbbell Lunge",    planWeightedAux(), restMins: 1.0),
        createKettlebell("Kettlebell Snatch (leg)",    "One-Arm Kettlebell Snatch", planWeightedAux(), restMins: 1.0),
        createKettlebell("Kettlebell Swing (leg)",     "Kettlebell Two Arm Swing", planWeightedAux(), restMins: 1.0),
        createDumbbell2("Step-ups (leg)",              "Step-ups",          planWeightedAux(), restMins: 1.0),

        // pull
        createVarSets("Chinup (pull)",         "Chinup",       planBodyAux(), restMins: 1.0, requestedReps: 50),
        createMachine("Face Pull (pull)",      "Face Pull",    planWeightedAux(), restMins: 1.0),
        createDumbbell2("Hammer Curls (pull)", "Hammer Curls", planWeightedAux(), restMins: 1.0),
        createVarSets("Inverted Row (pull)",   "Inverted Row", planBodyAux(), restMins: 1.0, requestedReps: 50),
        createMachine("Lat Pulldown (pull)",   "Lat Pulldown", planWeightedAux(), restMins: 1.5),
        createBarBell("Pendlay Row (pull)",    "Pendlay Row",  planWeightedAux(), restMins: 1.5),
        
        // push
        createVarSets("Dips (push)",             "Dips",                    planBodyAux(), restMins: 1.0, requestedReps: 50),
        createDumbbell2("Dumbbell Bench Press (push)", "Dumbbell Bench Press", planWeightedAux(), restMins: 1.0),
        createVarSets("Push Ups (push)",         "Pushup",                  planBodyAux(), restMins: 1.0, requestedReps: 50),
        createDumbbell1("Triceps Press (push)",  "Seated Triceps Press",    planWeightedAux(), restMins: 1.0),
        createMachine("Triceps Pushdown (push)", "Triceps Pushdown (rope)", planWeightedAux(), restMins: 1.5),

        createFixed("Foam Rolling",            "IT-Band Foam Roll",         planFixedMob(1, 15), restMins: 0.0),
        createFixed("Shoulder Dislocates",     "Shoulder Dislocate",        planFixedMob(1, 12), restMins: 0.0),
        createFixed("Bent-knee Iron Cross",    "Bent-knee Iron Cross",      planFixedMob(1, 10), restMins: 0.0),
        createFixed("Roll-over into V-sit",    "Roll-over into V-sit",      planFixedMob(1, 15), restMins: 0.0),
        createFixed("Rocking Frog Stretch",    "Rocking Frog Stretch",      planFixedMob(1, 10), restMins: 0.0),
        createFixed("Fire Hydrant Hip Circle", "Fire Hydrant Hip Circle",   planFixedMob(1, 10), restMins: 0.0),
        createFixed("Mountain Climber",        "Mountain Climber",          planFixedMob(1, 10), restMins: 0.0),
        createFixed("Cossack Squat",           "Cossack Squat",             planFixedMob(1, 10), restMins: 0.0),
        createTimed("Piriformis Stretch",      "Seated Piriformis Stretch", planTimedMob(2), duration: 30),
        createTimed("Hip Flexor Stretch",      "Rear-foot-elevated Hip Flexor Stretch", planTimedMob(2), duration: 30)]
    
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
    
    let tags: [Program.Tags] = [.beginner, .strength, .barbell, .threeDays, .ageUnder40, .age40s, .age50s]
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

