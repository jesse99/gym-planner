/// Masters program with cycles of 3x5, 3x3,and 3x1.
import Foundation

func HML() -> Program {
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
    
    func planLSquat() -> Plan {
        return PercentOfPlan("Light Squat",  "Squat",       firstWarmup: 0.5, warmupReps: [5, 3, 1, 1],    workSets: 1, workReps: 5, percent: 0.88)
    }
    
    func planMSquat() -> Plan {
        return PercentOfPlan("Medium Squat", "Squat",       firstWarmup: 0.5, warmupReps: [5, 3, 1, 1, 1], workSets: 2, workReps: 5, percent: 0.94)
    }
    
    func planMBench() -> Plan {
        return PercentOfPlan("Medium Bench", "Bench Press", firstWarmup: 0.5, warmupReps: [5, 3, 1, 1, 1], workSets: 2, workReps: 5, percent: 0.94)
    }
    
    func planChin() -> Plan {
        return VariableSetsPlan("Chins", requiredReps: 10, targetReps: 30)
    }
    
    let exercises = [
        createBarBell("Squat",          "Low bar Squat",  plan531(),    restSecs: 3.0, warmupsWithBar: 4),
        createBarBell("Bench Press",    "Bench Press",    plan531(),    restSecs: 3.0),
        createBarBell("Deadlift",       "Deadlift",       planDead(),   restSecs: 3.5, useBumpers: true),
        createBarBell("Light Squat",    "Low bar Squat",  planLSquat(), restSecs: 2.0, warmupsWithBar: 4, derived: true),
        createBarBell("Overhead Press", "Overhead Press", plan53(),     restSecs: 3.0, magnets: [1.25]),
        createFixed  ("Chinups",        "Chinup",         planChin(),   restSecs: 2.0),
        createBarBell("Medium Squat",   "Low bar Squat",  planMSquat(), restSecs: 3.0, warmupsWithBar: 4, derived: true),
        createBarBell("Medium Bench",   "Bench Press",    planMBench(), restSecs: 3.0, derived: true)]

    let workouts = [
        Workout("Heavy Day",  ["Squat",        "Bench Press",    "Deadlift"], scheduled: true),
        Workout("Medium Day", ["Medium Squat", "Medium Bench",   "Chinups"], scheduled: true),
        Workout("Light Day",  ["Light Squat",  "Overhead Press", "Chinups"], scheduled: true)]

    let tags: [Program.Tags] = [.intermediate, .strength, .age40s, .age50s]
    let description = """
This is the program I use and is based on the HLM program from the book _The Barbell Prescription: Strength Training for Life After 40_. It uses a very gradual progression and the heavy day cycles between sets of 5, 3, and 1 reps with the weight increasing each time the reps go down. It's a three day a week program and the days look like this:

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
Chinps are done with as many sets as are required, once you can do thirty add weights. Weights on the barbell routines advance unless you stall on the set with five reps. The medium and light days are switched which probably isn't ideal but works better with my schedule.
"""
    return Program("HML", workouts, exercises, tags, description)
}
