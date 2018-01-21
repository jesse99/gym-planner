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
    
    func planVarSetsAux() -> Plan {
        let targetReps = 50
        return VariableSetsPlan("\(targetReps) target", targetReps: targetReps)
    }
    
    func planCycleRepsAux() -> Plan {
        let numSets = 4
        let minReps = 6
        let maxReps = 12
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
        createVarReps("Box Jumps",      "Box Jump",       planBoxJump(), restMins: 0.0, requestedReps: 10),

        createBarBell("Squat",          "Low bar Squat",  planMain(),  restMins: 2.0),
        createBarBell("Deadlift",       "Deadlift",       planMain(),  restMins: 2.0, useBumpers: true),
        createBarBell("Bench Press",    "Bench Press",    planMain(),  restMins: 1.5, magnets: [1.25]),
        createBarBell("Overhead Press", "Overhead Press", planMain(),  restMins: 1.5, magnets: [1.25]),
        
        // single leg/core
        createVarSets("Ab Wheel Rollout", "Ab Wheel Rollout", planVarSetsAux(), restMins: 1.0, requestedReps: 25),

        // pull
        createCycleReps("Lat Pulldown", "Lat Pulldown", planCycleRepsAux(), restMins: 1.5),
        
        // push
        createVarSets("Push Ups", "Pushup", planVarSetsAux(), restMins: 1.0, requestedReps: 25),

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
    
    // TODO:
    // use two default accessories
    // add optional med ball throws to each workout
    // add lots of missing accessories
    let workouts = [
        Workout("Squat",    ["Box Jumps", "Squat",       "Bench Press",    "Ab Wheel Rollout"], scheduled: true, optional: []),
        Workout("Deadlift", ["Box Jumps", "Deadlift",    "Overhead Press", "Lat Pulldown"], scheduled: true, optional: []),
        Workout("Bench",    ["Box Jumps", "Bench Press", "Squat",          "Push Ups"], scheduled: true, optional: []),
        Workout("Mobility", ["Foam Rolling", "Shoulder Dislocates", "Bent-knee Iron Cross", "Roll-over into V-sit", "Rocking Frog Stretch", "Fire Hydrant Hip Circle", "Mountain Climber", "Cossack Squat", "Piriformis Stretch", "Hip Flexor Stretch"], scheduled: false)]
    
    let tags: [Program.Tags] = [.beginner, .strength, .barbell, .threeDays, .ageUnder40, .age40s, .age50s]
    let description = """
This [program](https://www.reddit.com/r/Fitness/wiki/531-beginners) is a variant of Jim Wendler's popular 531 program designed for beginners. It uses a three week cycle with 5+, 3+, and 1+ reps within each cycle and higher weights as the reps drop. Once the cycle finishes you have the option of adding weight, deloading, or keeping the weights the same. Progression is slower with this program than most of the other beginner programs but it's also a program than you can run for longer than the other programs. It's a three day a week program and the days look like this:

**Squat**
* Squat 5,3,1   reps change each week
* Bench 5,3,1
* Assistence work

**Deadlift**
* Deadlift 5,3,1   reps change each week
* Overhead Press 5,3,1
* Assistence work

**Bench**
* Bench 5,3,1   reps change each week
* Squat 5,3,1
* Assistence work

**Notes**
* The main lifts ascend to either 5+, 3+, or 1+ reps and then have a back off set.
* For the N+ sets do as many reps as you can but stop when the bar either starts to slow significantly or your form starts to break down.
* For the upper body main lifts you'll need 1.25 pound plates or magnets.
* There are a lot of options for the assistence work. Use the workout's options screen to switch between these. Wendler recommends 50-100 reps spread across one or two assistence exercises so be sure to keep weights low.
* Wendler recommends performing the mobility exercises before each workout as well as on the off days. The original recomendation was for [Agile 8](https://www.t-nation.com/training/defranco-agile-8) but this version uses [Limber 11](https://www.bodybuilding.com/fun/limber-11-the-only-lower-body-warm-up-youll-ever-need.html) which is the updated version from DeFranco.
* Wendler recommends cardio work to be performed three days a week between lifting days.
* It's recommended than you do a deload after completing five full cycles (the deload menu item will be bolded after five full cycles).
* You can also do a deload if you missed a rep within the cycle but normally you should only do so if it's a persistent problem and not something like one night of bad sleep.
"""
    return Program("531 Beginner", workouts, exercises, tags, description)
}

