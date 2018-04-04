/// Programs from n-Suns.
import Foundation

fileprivate typealias Set = FiveThreeOneLPPlan.WorkSet

fileprivate let programSuffix = """
Each day has a main lift, a secondary lift, and customizable assistence lifts. The main lift works up to a 1+ AMRAP set followed by six backoff sets. The secondary lift is done at less intensity and has two warmups followed by six work sets. Assistence work is typically three sets at 8-12 reps. For the main lifts weights should be increased based on how well you did on the 1+ set:
* If you did 0-1 reps then don't increase the weight.
* If you did 2-3 reps then increase the weight by one step (n-Suns recommends five pounds).
* If you did 4-5 reps then increase the weight by one or two steps.
* If you did 6+ reps then increase the weight by two or three steps.
"""

fileprivate let notes = """
* This program uses a lot of sets at a relatively low intensity so be conservative with your initial weights.
* You can do up to four assistence lifts during a workout.
* The assistence lifts should be tailored to address your weak areas.
* Wendler recommends a 10% deload for a lift if you think you've stalled on it.
"""

fileprivate func set(_ reps: Int, at: Double) -> Set {
    return Set(reps: reps, at: at)
}

fileprivate func amrap(_ reps: Int, at: Double) -> Set {
    return Set(amrap: reps, at: at)
}

fileprivate func pset(_ reps: Int, at: Double) -> PercentsOfPlan.WorkSet {
    return PercentsOfPlan.WorkSet(reps: reps, at: at)
}

fileprivate func pamrap(_ reps: Int, at: Double) -> PercentsOfPlan.WorkSet {
    return PercentsOfPlan.WorkSet(amrap: reps, at: at)
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

fileprivate func createOHP() -> Exercise {
    let sets = [set(5, at: 0.75), set(3, at: 0.85), amrap(1, at: 0.95), set(3, at: 0.90), set(3, at: 0.85), set(3, at: 0.80), set(5, at: 0.75), set(5, at: 0.70), amrap(5, at: 0.65)]
    return barbell531LP("Overhead Press", "Overhead Press", useBumpers: false, magnets: [], restMins: 2.0, sets, workSetPercent: 0.95, planName: "ohp")
}

// secondary lifts
fileprivate func createPercentsBench() -> Exercise {
    let sets = [pset(8, at: 0.65), pset(6, at: 0.75), pset(4, at: 0.85), pset(4, at: 0.85), pset(4, at: 0.85), pset(5, at: 0.80), pset(6, at: 0.75), pset(7, at: 0.70), pamrap(8, at: 0.65)]
    return barbellPercents("Light Bench", "Bench Press", of: "Bench Press", restMins: 2.0, sets, workSetPercent: 0.85, planName: "light bench")
}

fileprivate func createPercentsOHP() -> Exercise {
    let sets = [pset(6, at: 0.50), pset(5, at: 0.60), pset(3, at: 0.70), pset(5, at: 0.70), pset(7, at: 0.70), pset(4, at: 0.70), pset(6, at: 0.70), pset(8, at: 0.70)]
    return barbellPercents("Light OHP", "Overhead Press", of: "Overhead Press", restMins: 2.0, sets, workSetPercent: 0.70, planName: "light ohp")
}

fileprivate func createPercentsDead() -> Exercise {
    let sets = [pset(3, at: 0.75), pset(3, at: 0.75), pset(3, at: 0.75), pset(3, at: 0.75), pset(3, at: 0.75), pset(3, at: 0.75), pset(3, at: 0.75), pset(3, at: 0.75)]
    return barbellPercents("Light Deadlift", "Deadlift", of: "Deadlift", restMins: 2.5, sets, workSetPercent: 0.75, planName: "light deadlift")
}

fileprivate func createPercentsFrontSquat() -> Exercise {
    let sets = [pset(3, at: 0.55), pset(3, at: 0.55), pset(3, at: 0.55), pset(3, at: 0.55), pset(3, at: 0.55), pset(3, at: 0.55), ]
    return barbellPercents("Light Front Squat", "Front Squat", of: "Front Squat", restMins: 2.5, sets, workSetPercent: 0.55, planName: "light front squat")
}

fileprivate func createLightOHP() -> Exercise {
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

fileprivate func createInclineBench() -> Exercise {
    let sets = [set(6, at: 0.40), set(5, at: 0.50), set(3, at: 0.60), set(5, at: 0.60), set(7, at: 0.60), set(4, at: 0.60), set(6, at: 0.60), set(8, at: 0.60)]
    return barbell531LP("Incline Bench", "Incline Bench Press", useBumpers: false, magnets: [], restMins: 2.0, sets, workSetPercent: 0.60, planName: "incline bench")
}

fileprivate func createFrontSquat() -> Exercise {
    let sets = [set(5, at: 0.35), set(5, at: 0.45), set(3, at: 0.55), set(5, at: 0.55), set(7, at: 0.55), set(4, at: 0.55), set(6, at: 0.55), set(8, at: 0.55)]
    return barbell531LP("Front Squat", "Front Squat", useBumpers: false, magnets: [], restMins: 3.0, sets, workSetPercent: 0.55, planName: "front squat")
}

func nSunsLP4() -> Program {
    let exercises = [
        createPercentsBench(),
        createSquat(),
        createBench(),
        createDead(),
        createLightOHP(),
        createSumo(),
        createCGBench(),
        createFrontSquat(),
        
        // accessories
        bodyWeight("Chinups",         "Chinup",           requestedReps: 15, targetReps: 36, restMins: 2.5),
        bodyWeight("Dips",            "Dips",             3, minReps: 8, maxReps: 12, restMins: 1.5),
        bodyWeight("Ab Wheel",        "Ab Wheel Rollout", 3, by: 12, restMins: 1.0),
        pairedPlates("Leg Press",     "Leg Press",        3, by: 12, restMins: 3.0),
        barbell("Barbell Shrugs",     "Barbell Shrug",    3, by: 12, restMins: 2.0),
        bodyWeight("Back Extensions", "Back Extension",   3, minReps: 8, maxReps: 12, restMins: 1.5),
        machine("Cable Crunches",     "Cable Crunch",     3, minReps: 8, maxReps: 12, restMins: 2.0)]
    
    let workouts = [
        Workout("Light",    ["Light Bench", "Overhead Press", "Chinups", "Dips"], scheduled: true, optional: []),
        Workout("Squat",    ["Squat", "Sumo Deadlift", "Ab Wheel", "Leg Press"], scheduled: true, optional: []),
        Workout("Bench",    ["Bench Press", "C.G. Bench Press", "Barbell Shrugs", "Chinups"], scheduled: true, optional: []),
        Workout("Deadlift", ["Deadlift", "Front Squat", "Back Extensions", "Cable Crunches"], scheduled: true)]
    
    let tags: [Program.Tags] = [.intermediate, .strength, .barbell, .fourDays, .unisex, .ageUnder40, .age40s]
    let description = """
    Four day [program](http://archive.is/2017.01.27-015129/https://www.reddit.com/r/Fitness/comments/5icyza/2_suns531lp_tdee_calculator_and_other_items_all/#selection-2129.0-2129.12) with weekly progression from redditor n-Suns. \(programSuffix)
    The program looks like this:
    
    **Light**
    * Bench
    * OHP
    * Chinups
    * Dips
    
    **Squat**
    * Squat
    * Sumo Deadlift
    * Ab Wheel
    * Leg Press
    
    **Bench**
    * Bench
    * Close-grip Bench
    * Shrugs
    * Chinups
    
    **Deadlift**
    * Deadlift
    * Front Squat
    * Back Extensions
    * Cable Crunch
    
    **Notes**
    \(notes)
    """
    return Program("2_Suns/4", workouts, exercises, tags, description)
}

func nSunsLP5() -> Program {
    let exercises = [
        createPercentsBench(),
        createPercentsOHP(),
        createSquat(),
        createBench(),
        createDead(),
        createOHP(),
        createSumo(),
        createCGBench(),
        createInclineBench(),
        createFrontSquat(),
        
        // accessories
        bodyWeight("Chinups",         "Chinup",           requestedReps: 15, targetReps: 36, restMins: 2.5),
        bodyWeight("Dips",            "Dips",             3, minReps: 8, maxReps: 12, restMins: 1.5),
        bodyWeight("Ab Wheel",        "Ab Wheel Rollout", 3, by: 12, restMins: 1.0),
        pairedPlates("Leg Press",     "Leg Press",        3, by: 12, restMins: 3.0),
        barbell("Barbell Shrugs",     "Barbell Shrug",    3, by: 12, restMins: 2.0),
        bodyWeight("Back Extensions", "Back Extension",   3, minReps: 8, maxReps: 12, restMins: 1.5),
        dumbbell("Dumbbell Flyes",    "Dumbbell Flyes",   3, minReps: 8, maxReps: 12, restMins: 1.5),
        machine("Cable Crunches",     "Cable Crunch",     3, minReps: 8, maxReps: 12, restMins: 2.0)]
    
    let workouts = [
        Workout("Light",    ["Light Bench", "Light OHP", "Chinups", "Dips"], scheduled: true, optional: []),
        Workout("Squat",    ["Squat", "Sumo Deadlift", "Ab Wheel", "Leg Press"], scheduled: true, optional: []),
        Workout("OHP",      ["Overhead Press", "Incline Bench", "Dumbbell Flyes", "Dips"], scheduled: true, optional: []),
        Workout("Deadlift", ["Deadlift", "Front Squat", "Back Extensions", "Cable Crunches"], scheduled: true),
        Workout("Bench",    ["Bench Press", "C.G. Bench Press", "Barbell Shrugs", "Chinups"], scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.intermediate, .strength, .barbell, .fiveDays, .unisex, .ageUnder40]
    let description = """
Five day [program](http://archive.is/2017.01.27-015129/https://www.reddit.com/r/Fitness/comments/5icyza/2_suns531lp_tdee_calculator_and_other_items_all/#selection-2129.0-2129.12) with weekly progression from redditor n-Suns. \(programSuffix)
The program looks like this:

**Light**
* Bench
* OHP
* Chinups
* Dips

**Squat**
* Squat
* Sumo Deadlift
* Ab Wheel
* Leg Press

**OHP**
* Overhead Press
* Incline Bench
* Dumbbell Flyes
* Dips

**Deadlift**
* Deadlift
* Front Squat
* Back Extensions
* Cable Crunch

**Bench**
* Bench
* Close-grip Bench
* Shrugs
* Chinups

**Notes**
\(notes)
"""
    return Program("2_Suns/5", workouts, exercises, tags, description)
}

func nSunsLPDead() -> Program {
    let exercises = [
        createPercentsBench(),
        createPercentsOHP(),
        createPercentsDead(),
        createPercentsFrontSquat(),
        createSquat(),
        createBench(),
        createDead(),
        createOHP(),
        createSumo(),
        createCGBench(),
        createInclineBench(),
        createFrontSquat(),
        
        // accessories
        bodyWeight("Chinups",         "Chinup",           requestedReps: 15, targetReps: 36, restMins: 2.5),
        bodyWeight("Dips",            "Dips",             3, minReps: 8, maxReps: 12, restMins: 1.5),
        bodyWeight("Ab Wheel",        "Ab Wheel Rollout", 3, by: 12, restMins: 1.0),
        pairedPlates("Leg Press",     "Leg Press",        3, by: 12, restMins: 3.0),
        barbell("Pendlay Row",        "Pendlay Row",      3, by: 12, restMins: 2.0),
        barbell("Barbell Shrugs",     "Barbell Shrug",    3, by: 12, restMins: 2.0),
        bodyWeight("Back Extensions", "Back Extension",   3, minReps: 8, maxReps: 12, restMins: 1.5),
        dumbbell("Dumbbell Flyes",    "Dumbbell Flyes",   3, minReps: 8, maxReps: 12, restMins: 1.5),
        machine("Cable Crunches",     "Cable Crunch",     3, minReps: 8, maxReps: 12, restMins: 2.0)]
    
    let workouts = [
        Workout("Light Upper",    ["Light Bench", "Light OHP", "Pendlay Row", "Dips"], scheduled: true, optional: ["Dips"]),
        Workout("Deadlift",       ["Deadlift", "Front Squat", "Chinups", "Ab Wheel"], scheduled: true, optional: ["Ab Wheel"]),
        Workout("OHP",            ["Overhead Press", "Incline Bench", "Dumbbell Flyes", "Dips"], scheduled: true, optional: ["Dips"]),
        Workout("Squat",          ["Squat", "Sumo Deadlift", "Ab Wheel", "Leg Press"], scheduled: true, optional: ["Leg Press"]),
        Workout("Bench",          ["Bench Press", "C.G. Bench Press", "Barbell Shrugs", "Pendlay Row"], scheduled: true, optional: ["Pendlay Row"]),
        Workout("Light Deadlift", ["Light Deadlift", "Light Front Squat", "Chinups", "Leg Press"], scheduled: true, optional: ["Leg Press"])]
    
    let tags: [Program.Tags] = [.intermediate, .strength, .barbell, .sixDays, .unisex, .ageUnder40]
    let description = """
    Six day [program](http://archive.is/2017.01.27-015129/https://www.reddit.com/r/Fitness/comments/5icyza/2_suns531lp_tdee_calculator_and_other_items_all/#selection-2129.0-2129.12) with weekly progression and a focus on deadlifting from redditor n-Suns. \(programSuffix)
    The program looks like this:
    
    **Light Upper**
    * Bench
    * OHP
    * Pendlay Row
    * Dips (disabled by default)
    
    **Deadlift**
    * Deadlift
    * Front Squat
    * Chinups
    * Ab Wheel (disabled by default)

    **OHP**
    * Overhead Press
    * Incline Bench
    * Dumbbell Flyes
    * Dips (disabled by default)
    
    **Squat**
    * Squat
    * Sumo Deadlift
    * Ab Wheel
    * Leg Press (disabled by default)
    
    **Bench**
    * Bench
    * Close-grip Bench
    * Barbell Shrugs
    * Pendlay Row (disabled by default)

    **Light Deadlift**
    * Deadlift
    * Front Squat
    * Chinups
    * Leg Press (disabled by default)

    **Notes**
    \(notes)
    * Use the Options button within a workout screen to enable the disabled exercises.
    """
    return Program("2_SunsDeadift/6", workouts, exercises, tags, description)
}

