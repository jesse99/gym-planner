/// Programs from n-Suns.
import Foundation

fileprivate typealias Set = FiveThreeOneLPPlan.WorkSet

fileprivate func set(_ reps: Int, at: Double) -> Set {
    return Set(reps: reps, at: at)
}

fileprivate func amrap(_ reps: Int, at: Double) -> Set {
    return Set(amrap: reps, at: at)
}

// main lifts
fileprivate func createSquat() -> Exercise {
    let sets = [set(5, at: 0.75), set(3, at: 0.85), amrap(1, at: 0.95), set(3, at: 0.90), set(3, at: 0.85), set(3, at: 0.80), set(5, at: 0.75), set(5, at: 0.70), amrap(5, at: 0.65)]
    return barbell531LP("Squat", "Low bar Squat", useBumpers: false, magnets: [], restMins: 2.0, sets, workSetPercent: 0.95, planName: "squat")
}

fileprivate func createBench() -> Exercise {
    let sets = [set(5, at: 0.75), set(3, at: 0.85), amrap(1, at: 0.95), set(3, at: 0.90), set(5, at: 0.85), set(3, at: 0.80), set(5, at: 0.75), set(3, at: 0.70), amrap(5, at: 0.65)]
    return barbell531LP("Bench Press", "Bench Press", useBumpers: false, magnets: [], restMins: 2.0, sets, workSetPercent: 0.95, planName: "bench")
}

fileprivate func createDead() -> Exercise {
    let sets = [set(5, at: 0.75), set(3, at: 0.85), amrap(1, at: 0.95), set(3, at: 0.90), set(3, at: 0.85), set(3, at: 0.80), set(5, at: 0.75), set(3, at: 0.70), amrap(3, at: 0.65)]
    return barbell531LP("Deadlift", "Deadlift", useBumpers: true, magnets: [], restMins: 2.0, sets, workSetPercent: 0.95, planName: "deadlift")
}

// secondary lifts
fileprivate func createOHP() -> Exercise {
    let sets = [set(6, at: 0.50), set(5, at: 0.60), set(3, at: 0.70), set(5, at: 0.70), set(7, at: 0.70), set(4, at: 0.70), set(6, at: 0.70), set(8, at: 0.70)]
    return barbell531LP("Overhead Press", "Overhead Press", useBumpers: false, magnets: [], restMins: 2.0, sets, workSetPercent: 0.70, planName: "ohp")
}

fileprivate func createSumo() -> Exercise {
    let sets = [set(5, at: 0.50), set(5, at: 0.60), set(3, at: 0.70), set(5, at: 0.70), set(7, at: 0.70), set(4, at: 0.70), set(6, at: 0.70), set(8, at: 0.70)]
    return barbell531LP("Sumo Deadlift", "Sumo Deadlift", useBumpers: true, magnets: [], restMins: 3.0, sets, workSetPercent: 0.70, planName: "sumo")
}

fileprivate func createCGBench() -> Exercise {
    let sets = [set(6, at: 0.40), set(5, at: 0.50), set(3, at: 0.60), set(5, at: 0.60), set(7, at: 0.60), set(4, at: 0.60), set(6, at: 0.60), set(8, at: 0.60)]
    return barbell531LP("C.G. Bench Press", "Close-Grip Bench Press", useBumpers: false, magnets: [], restMins: 2.0, sets, workSetPercent: 0.60, planName: "cg bench")
}

fileprivate func createFrontSquat() -> Exercise {
    let sets = [set(5, at: 0.35), set(5, at: 0.45), set(3, at: 0.55), set(5, at: 0.55), set(7, at: 0.55), set(4, at: 0.55), set(6, at: 0.55), set(8, at: 0.55)]
    return barbell531LP("Front Squat", "Front Squat", useBumpers: false, magnets: [], restMins: 3.0, sets, workSetPercent: 0.55, planName: "front squat")
}

// accessories

func nSunsLP4() -> Program {
    let exercises = [
        createSquat(),
        createBench(),
        createDead(),
        createOHP(),
        createSumo(),
        createCGBench(),
        createFrontSquat()]
    
    let workouts = [
        Workout("Light",    ["Overhead Press"],    scheduled: true, optional: []),
        Workout("Squat",    ["Squat", "Sumo Deadlift"], scheduled: true, optional: []),
        Workout("Bench",    ["Bench Press", "C.G. Bench Press"],          scheduled: true, optional: []),
        Workout("Deadlift", ["Deadlift", "Front Squat"], scheduled: false)]
    
    let tags: [Program.Tags] = [.intermediate, .strength, .barbell, .fourDays, .unisex, .ageUnder40, .age40s]
    let description = """
Four day [program](http://archive.is/2017.01.27-015129/https://www.reddit.com/r/Fitness/comments/5icyza/2_suns531lp_tdee_calculator_and_other_items_all/#selection-2129.0-2129.12) with weekly progression from redditor n-Suns. Each day has a main lift, a secondary lift, and customizable assistence lifts. The main lift works up to a 1+ AMRAP set followed by six backoff sets. The secondary lift is done at less intensity and has two warmups followed by six work sets. Assistence work is typically three sets at 8-12 reps. For the main lifts weights should be increased based on how well you did on the 1+ set:
* If you did 0-1 reps then don't increase the weight.
* If you did 2-3 reps then increase the weight by one step (n-Suns recommends five pounds).
* If you did 4-5 reps then increase the weight by one or two steps.
* If you did 6+ reps then increase the weight by two or three steps.
The program looks like this:

**Light**
* Bench
* OHP
* Chinups
* Lateral Raise

**Squat**
* Squat
* Sumo Deadlift
* Cable Crunch

**Bench**
* Bench
* Close-grip Bench
* Chinups
* Pendlay Row

**Deadlift**
* Deadlift
* Front Squat
* Back Extensions
* Cable Crunch

**Notes**
* You can do up to four assistence lifts during a workout.
* The assistence lifts should be tailored to address your weak areas.
"""
    return Program("2_Suns/4", workouts, exercises, tags, description)
}


