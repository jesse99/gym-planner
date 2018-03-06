import Foundation

fileprivate let glutealNotes = """
* Attempt to increase weights by 5-10 pounds each week.
* Focus on activating the glutes with each exercise.
* When performing a single leg/arm exercise begin with the weaker limb and then do the same number of reps with the stronger limb.
* If you're having an off day don't continue a set if your form begins to break down.
* Unlike the other Strong Curves workouts this one is not set up for super-setting.
* Once you've done all the indicated workouts the app will prompt you to move onto the next program.
"""

// Weeks 1-4 for 3 days/week version of Gorgeous Glutes.
func GorgeousGlutes1() -> Program {
    let exercises = [
        // A
        bodyWeight("Hip Thrust",      "Hip Thrust",         3, by: 20, restMins: 1.5),
        bodyWeight("Squat",           "Body-weight Squat",  3, by: 20, restMins: 1.5),
        bodyWeight("Back Extension",  "Back Extension",     3, by: 20, restMins: 1.0),
        bodyWeight("Side Lying Clam", "Clam",               1, by: 30, restMins: 0.5),

        // B
        bodyWeight("Single-leg Glute Bridge", "Single Leg Glute Bridge",   3, by: 20, restMins: 1.5),
        bodyWeight("Walking Lunge",           "Body-weight Walking Lunge", 3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Reverse Hyperextension",  "Reverse Hyperextension",    3, by: 20, restMins: 1.0),
        bodyWeight("Side Lying Abduction",    "Side Lying Abduction",      1, by: 30, restMins: 1.0),

        // C
        barbell("Glute Bridge",       "Glute Bridge",               3, by: 10, restMins: 2.0),
        dumbbell("Goblet Squat",      "Goblet Squat",               3, by: 10, restMins: 2.0),
        dumbbell("Romanian Deadlift", "Dumbbell Romanian Deadlift", 3, by: 10, restMins: 2.0),
        machine("Cable Hip Rotation", "Cable Hip Rotation",         1, by: 10, restMins: 1.0)]
    
    let aExercises = ["Hip Thrust", "Squat", "Back Extension", "Side Lying Clam"]
    let bExercises = ["Single-leg Glute Bridge", "Walking Lunge", "Reverse Hyperextension", "Side Lying Abduction"]
    let cExercises = ["Glute Bridge", "Goblet Squat", "Romanian Deadlift", "Cable Hip Rotation"]
    
    let workouts = [
        Workout("A", aExercises, scheduled: true, optional: []),
        Workout("B", bExercises, scheduled: true, optional: []),
        Workout("C", cExercises, scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is weeks 1-4 of the stripped down beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows:
    
    **Workout A**
    * Bodyweight Hip Thrust 3x20
    * Bodyweight Full Squat 3x20
    * Bodyweight Back Extension 3x20
    * Side Lying Clam 1x30 (per side)
    
    **Cardio**
    
    **Workout B**
    * Bodyweight Single-leg Glute Bridge 3x20 (per side)
    * Bodyweight Walking Lunge 3x10-20 (per side)
    * Bodyweight Reverse Hyperextension 3x20
    * Side Lying Abduction 1x30 (per side)
    
    **Cardio**
    
    **Workout C**
    * Barbell Glute Bridge 3x10
    * Goblet Squat 3x10
    * Dumbbell Romanian Deadlift 3x10
    * Cable Hip Rotation 1x10 (per side)
    
    **Cardio**
    
    **Rest**
    
    **Notes**
    \(glutealNotes)
    """
    return Program("Gorgeous Glutes 1-4", workouts, exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Gorgeous Glutes 5-8")
}

// Weeks 5-8 for 3 days/week version of Gorgeous Glutes.
func GorgeousGlutes2() -> Program {
    let exercises = [
        // A
        barbell("Hip Thrust",               "Hip Thrust",            3, minReps: 8, maxReps: 12, restMins: 2.0),
        barbell("Front Squat",              "Front Squat",           3, minReps: 8, maxReps: 12, restMins: 2.0),
        barbell("Romanian Deadlift",        "Romanian Deadlift",     3, minReps: 8, maxReps: 12, restMins: 2.0),
        bodyWeight("Band Seated Abduction", "Band Seated Abduction", 1, by: 30, restMins: 1.0),

        // B
        bodyWeight("Single-leg Hip Thrust",      "Body-weight Single Leg Hip Thrust",  3, minReps: 8, maxReps: 12, restMins: 1.5),
        bodyWeight("Skater Squat",               "Skater Squat",                       3, minReps: 8, maxReps: 12, restMins: 1.5),
        dumbbell("Single-leg Romanian Deadlift", "Single Leg Romanian Deadlift",       3, minReps: 8, maxReps: 12, restMins: 1.5),
        machine("Cable Hip Abduction",           "Cable Hip Abduction",                1, by: 30, restMins: 0.5),

        // C
        barbell("Glute Bridge",            "Glute Bridge",         3, by: 10, restMins: 1.5),
        barbell("Zercher Squat",           "Zercher Squat",        3, by: 10, restMins: 1.5),
        dumbbell("Back Extension",         "Back Extension",       3, by: 10, restMins: 1.0),
        bodyWeight("Side Lying Hip Raise", "Side Lying Hip Raise", 1, by: 12, restMins: 1.0)]

    let aExercises = ["Hip Thrust", "Front Squat", "Romanian Deadlift", "Band Seated Abduction"]
    let bExercises = ["Single-leg Hip Thrust", "Skater Squat", "Single-leg Romanian Deadlift", "Cable Hip Abduction"]
    let cExercises = ["Glute Bridge", "Zercher Squat", "Back Extension", "Side Lying Hip Raise"]
    
    let workouts = [
        Workout("A", aExercises, scheduled: true, optional: []),
        Workout("B", bExercises, scheduled: true, optional: []),
        Workout("C", cExercises, scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is weeks 5-8 of the stripped down beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows:
    
    **Workout A**
    * Barbell Hip Thrust 3x8-12
    * Barbell Front Squat 3x8-12
    * Barbell Romanian Deadlift 3x8-12
    * Band Seated Abduction 1x30
    
    **Cardio**
    
    **Workout B**
    * Bodyweight Single-leg Hip Thrust 3x8-12 (per side)
    * Bodyweight Skater Squat 3x8-12 (per side)
    * Dumbbell Single-leg Romanian Deadlift 3x8-12 (per side)
    * Cable Standing Abduction 1x30 (per side)
    
    **Cardio**
    
    **Workout C**
    * Barbell Glute Bridge 3x10
    * Barbell Zercher Squat 3x10
    * Dumbbell Back Extension 3x10
    * Side-lying Hip Raise 1x12
    
    **Cardio**
    
    **Rest**
    
    **Notes**
    \(glutealNotes)
    """
    return Program("Gorgeous Glutes 5-8", workouts, exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Gorgeous Glutes 9-12")
}

// Weeks 9-12 for 3 days/week version of Gorgeous Glutes.
func GorgeousGlutes3() -> Program {
    let exercises = [
        // A
        barbell("Hip Thrust (constant tension)",  "Hip Thrust (constant tension)",           3, by: 20, restMins: 2.0),
        dumbbell("Deficit Bulgarian Split Squat", "Dumbbell Single Leg Split Squat",         3, by: 12, restMins: 2.0),
        barbell("Deadlift",                       "Deadlift",                                3, by: 8, restMins: 2.0),
        machine("Anti-Rotation Press",            "Half-kneeling Cable Anti-Rotation Press", 1, by: 15, restMins: 1.0),
        
        // B
        bodyWeight("Elevated Single-leg Hip Thrust (pause rep)", "Body-weight Single Leg Hip Thrust", 3, by: 6, restMins: 1.5),
        barbell("Box Squat",                    "Box Squat",           3, by: 6, restMins: 1.5),
        bodyWeight("Single-leg Back Extension", "Back Extension",      3, by: 12, restMins: 1.0),
        machine("Cable Hip Abduction",          "Cable Hip Abduction", 1, by: 15, restMins: 0.5),

        // C
        barbell("Hip Thrust (rest pause)", "Hip Thrust (rest pause)",  3, by: 10, restMins: 2.0),
        dumbbell("Step Ups",               "Step-ups",                 3, by: 8, restMins: 1.5),
        barbell("Kettlebell Swing",        "Kettlebell Two Arm Swing", 3, by: 20, restMins: 1.5),
        bodyWeight("Side Lying Hip Raise", "Side Lying Hip Raise",     1, by: 15, restMins: 1.0)]
    
    let aExercises = ["Elevated Single-leg Hip Thrust (pause rep)", "Box Squat", "Single-leg Back Extension", "Cable Hip Abduction"]
    let bExercises = ["Glute Bridge", "Zercher Squat", "Side Lying Hip Raise", "Cable Hip Rotation"]
    let cExercises = ["Hip Thrust (rest pause)", "Step Ups", "Kettlebell Swing", "Side Lying Hip Raise"]
    
    let workouts = [
        Workout("A", aExercises, scheduled: true, optional: []),
        Workout("B", bExercises, scheduled: true, optional: []),
        Workout("C", cExercises, scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .gym, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is weeks 9-12 of the stripped down beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows:
    
    **Workout A**
    * Barbell Hip Thrust (constant tension) 3x20
    * Dumbbell Deficit Bulgarian Split Squat 3x12 (per side)
    * Barbell Deadlift 3x8
    * Half-kneeling Cable Anti-Rotation Press 1x15 (per side)

    **Cardio**
    
    **Workout B**
    * Bodyweight Shoulder/foot Elevated Single-leg Hip Thrust (pause rep) 3x6
    * Barbell High Box Squat 3x6
    * Single-leg Back Extension 3x12 (per side)
    * Cable Hip Rotation 1x15
    
    **Cardio**
    
    **Workout C**
    * Barbell Hip Thrust (rest pause) 3x10
    * Dumbbell High Steup 3x8 (per side)
    * Russian Kettlebell Swing 3x20
    * Side Lying Hip Raise 1x15 (per side)
    
    **Cardio**
    
    **Rest**
    
    **Notes**
    \(glutealNotes)
    * After finishing the four weeks Brett recommends that you do a deload week, e.g. by reducing weights 20-50%.
    """
    return Program("Gorgeous Glutes 9-12", workouts, exercises, tags, description)
}



