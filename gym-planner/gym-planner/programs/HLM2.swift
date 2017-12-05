/// Masters program with cycles of 3x5, 3x3,and 3x1.
import Foundation

func HLM2() -> Program {
    func cycle(_ worksets: Int, by: Int, at: Double) -> MastersBasicCyclePlan.Execute {
        return MastersBasicCyclePlan.Execute(workSets: worksets, workReps: by, percent: at)
    }
    
    func plan531() -> Plan {
        return MastersBasicCyclePlan("531",  [cycle(3, by: 5, at: 1.0), cycle(3, by: 3, at: 1.05), cycle(3, by: 1, at: 1.1)])
    }
    
    func plan53() -> Plan {
        return MastersBasicCyclePlan("53",   [cycle(3, by: 5, at: 1.0), cycle(3, by: 3, at: 1.055)])
    }
    
    func planDead() -> Plan {
        return MastersBasicCyclePlan("Dead", [cycle(1, by: 5, at: 1.0), cycle(1, by: 3, at: 1.05), cycle(1, by: 1, at: 1.1)])
    }
    
    // TODO: temp
    func planSquat() -> Plan {
        return LinearPlan("Squat", firstWarmup: 0.5, warmupReps: [5, 3, 1, 1, 1], workSets: 3, workReps: 5)
    }
    
    func planLSquat() -> Plan {
        return PercentOfPlan("Light Squat",  firstWarmup: 0.5, warmupReps: [5, 3, 1, 1],    workSets: 1, workReps: 5, percent: 0.88)
    }
    
    func planMSquat() -> Plan {
        return PercentOfPlan("Medium Squat", firstWarmup: 0.5, warmupReps: [5, 3, 1, 1, 1], workSets: 2, workReps: 5, percent: 0.94)
    }
    
    func planMBench() -> Plan {
        return PercentOfPlan("Medium Bench", firstWarmup: 0.5, warmupReps: [5, 3, 1, 1, 1], workSets: 2, workReps: 5, percent: 0.94)
    }
    
    func planChin() -> Plan {
        return VariableSetsPlan("Chinups", targetReps: 50)
    }
    
    func planTimed(_ numSets: Int) -> Plan {
        return TimedPlan("\(numSets) timed sets", numSets: numSets, targetTime: nil)
    }

    func planFixed(_ numSets: Int, _ numReps: Int) -> Plan {
        return FixedSetsPlan("fixed \(numSets)x\(numReps)", numSets: numSets, numReps: numReps)
    }
    
    let exercises = [
        createBarBell("Squat",          "Low bar Squat",  planSquat(),  restMins: 3.0, warmupsWithBar: 3),
        createBarBell("Bench Press",    "Bench Press",    plan531(),    restMins: 3.0),
        createBarBell("Deadlift",       "Deadlift",       planDead(),   restMins: 3.5, useBumpers: true),
        createBarBell("Light Squat",    "Low bar Squat",  planLSquat(), restMins: 2.0, warmupsWithBar: 3, derivedFrom: "Squat"),
        createBarBell("Overhead Press", "Overhead Press", plan53(),     restMins: 3.0, magnets: [1.25]),
        createReps   ("Chinups",        "Chinup",         planChin(),   restMins: 2.0, requestedReps: 10),
        createBarBell("Medium Squat",   "Low bar Squat",  planMSquat(), restMins: 3.0, warmupsWithBar: 3, derivedFrom: "Squat"),
        createBarBell("Medium Bench",   "Bench Press",    planMBench(), restMins: 3.0, derivedFrom: "Bench Press"),
        
        createFixed("Shoulder Dislocates",     "Shoulder Dislocate",        planFixed(1, 12), restMins: 0.0),
        createFixed("Bent-knee Iron Cross",    "Bent-knee Iron Cross",      planFixed(1, 10), restMins: 0.0),
        createFixed("Roll-over into V-sit",    "Roll-over into V-sit",      planFixed(1, 15), restMins: 0.0),
        createFixed("Rocking Frog Stretch",    "Rocking Frog Stretch",      planFixed(1, 10), restMins: 0.0),
        createFixed("Fire Hydrant Hip Circle", "Fire Hydrant Hip Circle",   planFixed(1, 10), restMins: 0.0),
        createFixed("Mountain Climber",        "Mountain Climber",          planFixed(1, 10), restMins: 0.0),
        createFixed("Cossack Squat",           "Cossack Squat",             planFixed(1, 10), restMins: 0.0),
        createTimed("Piriformis Stretch",      "Seated Piriformis Stretch", planTimed(1), duration: 30),
        createFixed("Hip Flexor Stretch",      "Rear-foot-elevated Hip Flexor Stretch", planFixed(1, 10), restMins: 0.0)]

    let workouts = [
        Workout("Mobility",   ["Shoulder Dislocates", "Bent-knee Iron Cross", "Roll-over into V-sit", "Rocking Frog Stretch", "Fire Hydrant Hip Circle", "Mountain Climber", "Cossack Squat", "Piriformis Stretch", "Hip Flexor Stretch"], scheduled: false),
        Workout("Heavy Day",  ["Squat",        "Bench Press",    "Deadlift"], scheduled: true),
        Workout("Light Day",  ["Light Squat",  "Overhead Press", "Chinups"], scheduled: true),
        Workout("Medium Day", ["Medium Squat", "Medium Bench",   "Chinups"], scheduled: true)]

    let tags: [Program.Tags] = [.intermediate, .strength, .age40s, .age50s]
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
* Chins up to 50 reps

These should feel like you are working hard without being in danger of missing a rep and with some energy left after each set.

**Light**
* Squat 1x5 at 88% of heavy's 5 rep weight
* OHP 3x5,3
* Chins up to 30 reps

All the reps should be fairly easy.

**Notes**
Chinps are done with as many sets as are required, once you can do fifty add weights. Weights on the barbell routines advance unless you stall on the set with five reps..
"""
    return Program("HLM2", workouts, exercises, tags, description)
}
