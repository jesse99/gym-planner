import Foundation

fileprivate let bestButtNotes = """
* This is a three day a week program designed to be performed at home.
* You'll need a bit of equipment for this program: an exercise mat, a swiss ball, valslides (or a towel if you have smooth floors). a chin-up bar, and a PVC pipe/dowel/broomstick.
* Don't be too aggressive about upping the rep ranges: the first and last reps you do should feel the same.
* When performing a single leg/arm exercise begin with the weaker limb and then do the same number of reps with the stronger limb.
* To speed up the workouts you can superset the exercises: do a set of a lower body exercise, a set of an upper body, rest for 60-120s, and repeat until you've finished all the sets for both exercises.
* Once you've done all the indicated workouts the app will prompt you to move onto the next program.
"""

// Weeks 1-4 for 3 days/week version of Best Butt.
func BestButt1() -> Program {
    let exercises = [
        // A
        bodyWeight("Glute Bridge",          "Glute Bridge",          3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Inverted Row",          "Inverted Row",          3, minReps: 8, maxReps: 12, restMins: 1.0),
        bodyWeight("Box Squat",             "Body-weight Box Squat", 3, minReps: 10, maxReps: 20, restMins: 1.5),
        bodyWeight("Incline Pushup",        "Incline Pushup",        3, minReps: 8, maxReps: 12, restMins: 1.0),
        bodyWeight("Hip Hinge with Dowel",  "Hip Hinge with Dowel",  3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Side Lying Abduction",  "Side Lying Abduction",  1, minReps: 10, maxReps: 30, restMins: 1.0),
        bodyWeight("Front Plank",           "Front Plank",           1, minSecs: 30, maxSecs: 120),
        bodyWeight("Side Plank from Knees", "Side Plank",            2, minSecs: 20, maxSecs: 60),
        
        // B
        bodyWeight("Elevated Single-leg Glute Bridge", "Single Leg Glute Bridge",      3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Negative Chinup",                  "Chinup",                       3, minReps: 1, maxReps: 3, restMins: 1.5),
        bodyWeight("Step-ups",                         "Deep Step-ups",                3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Pushup from Knees",                "Pushup",                       3, minReps: 5, maxReps: 15, restMins: 1.0),
        bodyWeight("Swiss Ball Back Extension",        "Exercise Ball Back Extension", 3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Side Plank from Knees",            "Side Plank",                   2, minSecs: 20, maxSecs: 60),
        bodyWeight("Situp",                            "Situp",                        1, minReps: 20, maxReps: 30, restMins: 1.0),
        bodyWeight("Oblique Crunches",                 "Oblique Crunches",             1, minReps: 20, maxReps: 30, restMins: 1.0),

        // C
        bodyWeight("Glute March",            "Glute March",               3, minSecs: 30, maxSecs: 60),
        bodyWeight("Inverted Row",           "Inverted Row",              3, minReps: 8, maxReps: 12, restMins: 1.0),
        bodyWeight("Box Squat",              "Body-weight Box Squat",     3, minReps: 10, maxReps: 20, restMins: 1.5),
        bodyWeight("Negative Pushup",        "Pushup",                    3, minReps: 3, maxReps: 5, restMins: 1.0),
        bodyWeight("Hip Hinge with Dowel",   "Hip Hinge with Dowel",      3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Side Lying Clam",        "Clam",                      1, minReps: 20, maxReps: 30, restMins: 1.0),
        bodyWeight("Straight Leg Situp",     "Straight Leg Situp",        1, minReps: 15, maxReps: 30, restMins: 1.0),
        bodyWeight("Swiss Ball Side Crunch", "Exercise Ball Side Crunch", 1, minReps: 15, maxReps: 30, restMins: 1.0)]
    
    let aExercises = ["Glute Bridge", "Inverted Row", "Box Squat", "Incline Pushup", "Hip Hinge with Dowel", "Side Lying Abduction", "Front Plank", "Side Plank from Knees"]
    let bExercises = ["Elevated Single-leg Glute Bridge", "Negative Chinup", "Step-ups", "Pushup from Knees", "Swiss Ball Back Extension", "Side Plank from Knees", "Situp", "Oblique Crunches"]
    let cExercises = ["Glute March", "Inverted Row", "Box Squat", "Negative Pushup", "Hip Hinge with Dowel", "Side Lying Clam", "Straight Leg Situp", "Swiss Ball Side Crunch"]
    
    let workouts = [
        Workout("A", aExercises, scheduled: true, optional: []),
        Workout("B", bExercises, scheduled: true, optional: []),
        Workout("C", cExercises, scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .minimal, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is the weeks 1-4 of the at home beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows:
    
    **Workout A**
    * Glute Bridge 3x10-20
    * Inverted Row 3x8-12
    * Box Squat 3x10-20
    * Incline Pushup 3x8-12
    * Hip Hinge with Dowel 3x10-20
    * Side Lying Abduction 1x10-30 (set per side)
    * Front Plank 1x30-120s
    * Side Plank from Knees 2x20-60s (one per side)
    
    **Cardio**
    
    **Workout B**
    * Foot Elevated Single-leg Glute Bridge 3x10-20 (set per side)
    * Negative Chinup 3x1-3
    * Step-up 3x10-20 (set per side)
    * Pushup from Knees 3x5-15
    * Swiss Ball Back Extension 3x10-20
    * Side Plank from Knees 2x20-60s (each side)
    * Crunch 1x20-30
    * Side Crunch 1x20-30 (each side)
    
    **Cardio**
    
    **Workout C**
    * Glute March 3x30-60s (alternating legs)
    * Inverted Row 3x8-12
    * Box Squat 3x10-20
    * Negative Pushup 3x3-5
    * Hip Hinge with Dowel 3x10-20
    * Side Lying Clam 1x20-30 (each side)
    * Straight-leg Situp 1x15-30
    * Swiss Ball Side Crunch 1x15-30 (eaxh side)

    **Cardio**
    
    **Rest**
    
    **Notes**
    \(bestButtNotes)
    """
    return Program("Best Butt 1-4", workouts, exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Best Butt 5-8")
}

// Weeks 5-8 for 3 days/week version of Best Butt.
func BestButt2() -> Program {
    let exercises = [
        // A
        bodyWeight("Hip Thrust",           "Body-weight Hip Thrust",          3, minReps: 10, maxReps: 30, restMins: 1.0),
        bodyWeight("Inverted Row",         "Inverted Row",                    3, minReps: 8, maxReps: 12, restMins: 1.0),
        bodyWeight("Squat",                "Body-weight Squat",               3, minReps: 10, maxReps: 30, restMins: 1.5),
        bodyWeight("Pushup",               "Pushup",                          3, by: 1, restMins: 1.0),
        bodyWeight("Single Leg Deadlift",  "Body-weight Single Leg Deadlift", 3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Side Lying Abduction", "Side Lying Abduction",            1, minReps: 10, maxReps: 30, restMins: 1.0),
        bodyWeight("RKC Plank",            "RKC Plank",                       1, minSecs: 20, maxSecs: 60),
        bodyWeight("Side Plank",           "Side Plank",                      2, minSecs: 20, maxSecs: 60),

        // B
        bodyWeight("Single-leg Glute Bridge", "Single Leg Glute Bridge",   3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Chinup",                  "Chinup",                    3, by: 1, restMins: 1.5),
        bodyWeight("Walking Lunge",           "Body-weight Walking Lunge", 3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Pushup from Knees",       "Pushup",                    3, minReps: 6, maxReps: 20, restMins: 1.5),
        bodyWeight("Reverse Hyperextension",  "Reverse Hyperextension",    3, minReps: 10, maxReps: 30, restMins: 1.0),
        bodyWeight("Side Lying Clam",         "Clam",                      1, minReps: 10, maxReps: 30, restMins: 1.0),
        bodyWeight("Swiss Ball Crunch",       "Exercise Ball Crunch",      1, minReps: 10, maxReps: 30, restMins: 1.0),
        bodyWeight("Swiss Ball Side Crunch",  "Exercise Ball Side Crunch", 1, minReps: 10, maxReps: 30, restMins: 1.0),

        // C
        bodyWeight("Hip Thrust",             "Body-weight Hip Thrust",    3, minReps: 10, maxReps: 30, restMins: 1.0),
        bodyWeight("Inverted Row",           "Inverted Row",              3, minReps: 8, maxReps: 12, restMins: 1.0),
        bodyWeight("High Step-ups",          "Deep Step-ups",             3, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Incline Pushup",         "Incline Pushup",            3, minReps: 8, maxReps: 12, restMins: 1.5),
        bodyWeight("Back Extension",         "Back Extension",            3, minReps: 20, maxReps: 30, restMins: 1.0),
        bodyWeight("Side Lying Hip Raise",   "Side Lying Hip Raise",      1, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Feet Elevated Plank",    "Front Plank",               1, minSecs: 60, maxSecs: 120),
        bodyWeight("Swiss Ball Side Crunch", "Exercise Ball Side Crunch", 1, minReps: 10, maxReps: 20, restMins: 1.0)]
    
    let aExercises = ["Hip Thrust", "Inverted Row", "Squat", "Pushup", "Single Leg Deadlift", "Side Lying Abduction", "RKC Plank", "Side Plank"]
    let bExercises = ["Single-leg Glute Bridge", "Chinup", "Walking Lunge", "Pushup from Knees", "Reverse Hyperextension", "Side Lying Clam", "Swiss Ball Crunch", "Swiss Ball Side Crunch"]
    let cExercises = ["Hip Thrust", "Inverted Row", "High Step-ups", "Incline Pushup", "Back Extension", "Side Lying Hip Raise", "Feet Elevated Plank",  "Swiss Ball Side Crunch"]
    
    let workouts = [
        Workout("A", aExercises, scheduled: true, optional: []),
        Workout("B", bExercises, scheduled: true, optional: []),
        Workout("C", cExercises, scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .minimal, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is weeks 5-8 of the at home beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows::
    
    **Workout A**
    * Hip Thrust 3x10-30
    * Inverted Row 3x8-12
    * Full Squat 3x10-30
    * Strict Pushup 3x1
    * Single-leg Romanian Deadlift 3x10-20 (set per side)
    * Side Lying Abduction 1x10-30 (set per side)
    * RKC Plank 1x20-60s
    * Side Plank 1x20-60s (set per side)
    
    **Cardio**
    
    **Workout B**
    * Single-leg Glute Bridge 3x10-20
    * Chinup 3x1
    * Walking Lunge 3x10-20
    * Pushup from knees 3x6-20
    * Reverse Hyperextension 3x10-30
    * Side Lying Clam 1x10-30 (set per side)
    * Swiss Ball Crunch 1x10-30
    * Swiss Ball Side Crunch 1x10-30 (set per side)
    
    **Cardio**
    
    **Workout C**
    * Hip Thrust 3x10-30
    * Inverted Row 3x8-12
    * High Step-up 3x10-20 (set per side)
    * Torso Elevated Pushup 3x8-12
    * Back Extension 3x20-30
    * Side-lying Hip Raise 1x10-20
    * Feet Elevated Plank 1x60-120s
    * Swiss Ball Side Crunch 1x10-20 (set per side)

    **Cardio**
    
    **Rest**
    
    **Notes**
    \(bestButtNotes)
    """
    return Program("Best Butt 5-8", workouts, exercises, tags, description, maxWorkouts: 3*4, nextProgram: "Best Butt 9-12")
}

// Weeks 9-12 for 3 days/week version of Best Butt.
func BestButt3() -> Program {
    let exercises = [
        // A
        bodyWeight("Elevated Single-leg Hip Thrust", "Body-weight Single Leg Hip Thrust",   3, minReps: 8, maxReps: 20, restMins: 1.0),
        bodyWeight("Chinup",                         "Chinup",                              3, minReps: 3, maxReps: 10, restMins: 1.5),
        bodyWeight("Step Up + Reverse Lunge",        "Body-weight Step Up + Reverse Lunge", 3, minReps: 10, maxReps: 15, restMins: 1.5),
        bodyWeight("Pushup",                         "Pushup",                              3, minReps: 5, maxReps: 10, restMins: 1.5),
        bodyWeight("Swiss Ball Back Extension",      "Exercise Ball Back Extension",        3, minReps: 8, maxReps: 20, restMins: 1.0),
        bodyWeight("Traverse Abduction",             "Quadruped Double Traverse Abduction", 1, by: 6, restMins: 1.0),
        bodyWeight("Prisoner Swiss Ball Crunch",     "Exercise Ball Crunch",                1, minReps: 10, maxReps: 30, restMins: 1.0),
        bodyWeight("Side Plank with Abduction",      "Side Plank",                          2, minSecs: 20, maxSecs: 60),

        // B
        bodyWeight("Elevated Hip Thrust",        "Body-weight Hip Thrust",             3, minReps: 6, maxReps: 20, restMins: 1.0),
        bodyWeight("Elevated Inverted Row",     "Inverted Row",                        3, minReps: 6, maxReps: 12, restMins: 1.0),
        bodyWeight("Bulgarian Split Squat",     "Body-weight Single Leg Glute Bridge", 3, minReps: 5, maxReps: 30, restMins: 1.0),
        bodyWeight("Elevated Pike Pushup",      "Pike Pushup",                         3, minReps: 6, maxReps: 20, restMins: 1.0),
        bodyWeight("Sliding Leg Curl",          "Sliding Leg Curl",                    2, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Standing Double Abduction", "Standing Double Abduction",           1, by: 6, restMins: 1.0),
        bodyWeight("RKC Plank",                 "RKC Plank",                           1, minSecs: 30, maxSecs: 60),
        bodyWeight("Elevated Side Plank",       "Side Plank",                          2, minSecs: 20, maxSecs: 60),

        // C
        bodyWeight("Elevated Single-leg Hip Thrust",     "Body-weight Hip Thrust", 3, minReps: 5, maxReps: 15, restMins: 1.5),
        bodyWeight("Pullup",                             "Pullup",                 3, minReps: 3, maxReps: 10, restMins: 1.5),
        bodyWeight("High Step-ups",                      "Deep Step-ups",          3, minReps: 10, maxReps: 15, restMins: 1.0),
        bodyWeight("Narrow-base Pushup",                 "Pushup",                 3, minReps: 3, maxReps: 8, restMins: 1.5),
        bodyWeight("Russian Leg Curls",                  "Russian Leg Curl",       3, minReps: 3, maxReps: 5, restMins: 1.0),
        bodyWeight("Side Lying Hip Raise",               "Side Lying Hip Raise",   1, minReps: 10, maxReps: 20, restMins: 1.0),
        bodyWeight("Body Saw",                           "Body Saw",               1, minReps: 10, maxReps: 15, restMins: 1.0),
        bodyWeight("Elevated Side Plank with Abduction", "Side Plank",             2, minSecs: 20, maxSecs: 60)]
    
    let aExercises = ["Elevated Single-leg Hip Thrust", "Chinup", "Step Up + Reverse Lunge", "Pushup", "Swiss Ball Back Extension", "Traverse Abduction", "Prisoner Swiss Ball Crunch", "Side Lying Abduction", "Side Plank with Abduction"]
    let bExercises = ["Elevated Hip Thrust", "Elevated Inverted Row", "Bulgarian Split Squat", "Elevated Pike Pushup", "Sliding Leg Curl", "Standing Double Abduction", "RKC Plank", "Elevated Side Plank"]
    let cExercises = ["Elevated Single-leg Hip Thrust", "Pullup", "High Step-ups", "Narrow-base Pushup", "Russian Leg Curls", "Side Lying Hip Raise", "Body Saw", "Elevated Side Plank with Abduction"]
    
    let workouts = [
        Workout("A", aExercises, scheduled: true, optional: []),
        Workout("B", bExercises, scheduled: true, optional: []),
        Workout("C", cExercises, scheduled: true, optional: [])]
    
    let tags: [Program.Tags] = [.beginner, .hypertrophy, .minimal, .threeDays, .female, .ageUnder40, .age40s, .age50s]
    let description = """
    This is weeks 9-12 of the at home beginner program from [Strong Curves: A Woman's Guide to Building a Better Butt and Body](https://www.amazon.com/Strong-Curves-Womans-Building-Better-ebook/dp/B00C4XI0QM/ref=sr_1_1?ie=UTF8&qid=1516764374&sr=8-1&keywords=strong+curves). The program is as follows:
    
    **Workout A**
    * Shoulder Elevated Single-leg Hip Thrust 3x8-20 (set per side)
    * Chinup 3x3-10
    * Step-up + Reverse Lunge 3x10-15 (set per side)
    * Pushup 3x5-10
    * Swiss Ball Back Extension 3x8-20 (set per side)
    * Quadreped Double Traverse Abduction 1x6
    * Prisoner Swiss Ball Crunch 1x10-30
    * Side Plank with Abduction 1x20-60s (each side)
    
    **Cardio**
    
    **Workout B**
    * Shoulder/foot Elevated Single-leg Hip Thrust 3x6-20 (set per side)
    * Feet Elevated Inverted Row 3x6-12
    * Bulgarian Split Squat 3x5-30 (set per side)
    * Feet Elevated Pike Pushup 3x6-20
    * Sliding Leg Curl 2x10-20
    * Standing Double Abduction 1x6
    * RKC Plank 1x30-60s
    * Feet Elevated Side Plank 1x20-60s (each side)
    
    **Cardio**
    
    **Workout C**
    * Shoulder Elevated Single-leg Hip Thrust (paused) 3x5-15 (set per side)
    * Pullup 3x3-10
    * High Step-up 3x10-15 (set per each side)
    * Narrow-base Pushup 3x3-8
    * Russian Leg Curls 3x3-5
    * Side Lying Hip Raise 1x10-20 (set per side)
    * Body Saw 1x10-15
    * Feet Elevated Side Plank with Abduction 1x20-60s (set per side)
    
    **Cardio**
    
    **Rest**
    
    **Notes**
    \(bestButtNotes)
    * After finishing the four weeks Brett recommends that you do a deload week, e.g. by reducing weights 20-50%.
    """
    return Program("Best Butt 9-12", workouts, exercises, tags, description)
}



