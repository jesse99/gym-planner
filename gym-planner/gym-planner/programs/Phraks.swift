/// Masters program with cycles of 3x5, 3x3,and 3x1.
import Foundation

func Phraks() -> Program {
    func chinsPlan() -> Plan {
        return VariableSetsPlan("Chinups", targetReps: 30)
    }
    
    func amrapPlan() -> Plan {
        return AMRAPPlan("AMRAP", firstWarmup: 0.4, warmupReps: [5, 5, 3], workSets: 3, workReps: 5)
    }
    
    let exercises = [
        createVarReps("Chinups",        "Chinup",         chinsPlan(), restMins: 2.5, requestedReps: 15),
        createBarBell("Overhead Press", "Overhead Press", amrapPlan(), restMins: 2.5, magnets: [1.25]),
        createBarBell("Squat",          "Low bar Squat",  amrapPlan(), restMins: 3.0, warmupsWithBar: 2),
        createBarBell("Barbell Rows",   "Pendlay Row",    amrapPlan(), restMins: 2.0, magnets: [1.25]),
        createBarBell("Bench Press",    "Bench Press",    amrapPlan(), restMins: 3.0, magnets: [1.25]),
        createBarBell("Deadlift",       "Deadlift",       amrapPlan(), restMins: 3.0, useBumpers: true)]
    
    let workouts = [
        Workout("OHP1",   ["Chinups",      "Overhead Press", "Squat"], scheduled: true, optional: []),
        Workout("Dead1",  ["Barbell Rows", "Bench Press",    "Deadlift"], scheduled: true, optional: []),
        Workout("OHP2",   ["Chinups",      "Overhead Press", "Squat"], scheduled: true, optional: []),

        Workout("Bench1", ["Barbell Rows", "Bench Press",    "Squat"], scheduled: true, optional: []),
        Workout("Dead2",  ["Chinups",      "Overhead Press", "Deadlift"], scheduled: true, optional: []),
        Workout("Bench2", ["Barbell Rows", "Bench Press",    "Squat"], scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .strength, .barbell, .threeDays, .ageUnder40]
    let description = """
This is a bare-bones [implementation](https://www.reddit.com/r/Fitness/wiki/phraks-gslp) of the [Greyskull linear progression program](https://strengthvillain.myshopify.com/collections/ebooks/products/greyskull-lp-third-edition). It's a three day a week program and the days look like this:

**OHP1**
* Chinups 3x5-30
* Overhead Press 3x5+
* Squats 3x5+

**Dead1**
* Barbell Rows 3x5+
* Bench Press 3x5+
* Deadlift 1x5+

**OHP2**
* Chinups 3x5-30
* Overhead Press 3x5+
* Squats 3x5+

**Bench1**
* Barbell Rows 3x5+
* Bench Press 3x5+
* Squats 3x5+

**Dead2**
* Chinups 3x5-30
* Overhead Press 3x5+
* Deadlift 1x5+

**Bench2**
* Barbell Rows 3x5+
* Bench Press 3x5+
* Squats 3x5+

**Notes**
* The plus means that the last set should be done As Many Times As Possible (AMRAP). But note that you shouldn't go to failure: instead stop one or two reps short of failure. One way to manage this is to stop when the bar begins to slow significantly.
* If you're able to do more than ten reps in an AMRAP set then you can optionally select Advance x2 when finishing the exercise.
* If you can't do five reps for each set of an exercise then select deload from the menu when finishing and the app will reduce the weight for that exercise by ten percent.
* If you cannot do chinups then do negative chinups.
* If you're able to do thirty chinups then add weight and drop the reps.
"""
    return Program("Phrak's GSLP", workouts, exercises, tags, description)
}

