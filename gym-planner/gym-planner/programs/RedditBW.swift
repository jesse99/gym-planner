import Foundation

func RedditBW() -> Program {
    let exercises = [
        // Warmup
        bodyWeight("Yuri's Shoulder Band", "Yuri's Shoulder Band", 1, by: 10, restMins: 0.5),
        bodyWeight("Squat Sky Reaches",    "Squat Sky Reaches",    1, by: 10, restMins: 0.5),
        bodyWeight("GMB Wrist Prep",       "GMB Wrist Prep",       1, by: 10, restMins: 0.5),
        bodyWeight("Deadbugs",             "Deadbugs",             1, minSecs: 10, maxSecs: 30),
        bodyWeight("Arch Hangs warmup",    "Arch Hangs",           1, by: 15, restMins: 0.5),
        bodyWeight("Support Hold",         "Parallel Bar Support", 1, minSecs: 10, maxSecs: 30),

        bodyWeight("Split Squat warmup",               "Body-weight Squat", 1, by: 10, restMins: 0.5),
        bodyWeight("Bulgarian Split Squat warmup",     "Body-weight Bulgarian Split Squat", 1, by: 10, restMins: 0.5),
        bodyWeight("Beginner Shrimp Squat warmup",     "Beginner Shrimp Squat", 1, by: 10, restMins: 0.5),
        bodyWeight("Intermediate Shrimp Squat warmup", "Intermediate Shrimp Squat", 1, by: 10, restMins: 0.5),
        bodyWeight("Advanced Shrimp Squat warmup",     "Advanced Shrimp Squat", 1, by: 10, restMins: 0.5),
        
        // Workout
        bodyWeight("Scapular Pulls",   "Scapular Pulls",  requestedReps: 15, targetReps: 25, restMins: 1.5),
        bodyWeight("Arch Hangs",       "Arch Hangs",      requestedReps: 15, targetReps: 25, restMins: 1.5),
        bodyWeight("Negative Pullups", "Pullup Negative", requestedReps: 15, targetReps: 25, restMins: 1.5),
        bodyWeight("Pullups",          "Pullup",          requestedReps: 15, targetReps: 25, restMins: 1.5),
        bodyWeight("Weighted Pullups", "Pullup",          requestedReps: 15, targetReps: 25, restMins: 1.5),

        bodyWeight("Split Squat",               "Body-weight Squat",                 3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Bulgarian Split Squat",     "Body-weight Bulgarian Split Squat", 3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Beginner Shrimp Squat",     "Beginner Shrimp Squat",             3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Intermediate Shrimp Squat", "Intermediate Shrimp Squat",         3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Advanced Shrimp Squat",     "Advanced Shrimp Squat",             3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Weighted Shrimp Squat",     "Advanced Shrimp Squat",             3, minReps: 5, maxReps: 8, restMins: 1.5),

        bodyWeight("Parallel Bar Support Hold", "Parallel Bar Support", 3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Negative Dips",             "Dips",                 3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Parallel Bar Dips",         "Dips",                 3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Weighted Dips",             "Dips",                 3, minReps: 5, maxReps: 8, restMins: 1.5),

        bodyWeight("Romanian Deadlift",           "Body-weight Romanian Deadlift",   3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Single-legged Deadlift",      "Body-weight Single Leg Deadlift", 3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Banded Negative Nordic Curl", "Banded Nordic Curl",              3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Banded Nordic Curl",          "Banded Nordic Curl",              3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Nordic Curls",                "Russian Leg Curl",                3, minReps: 5, maxReps: 8, restMins: 1.5),

        bodyWeight("Vertical Rows",          "Vertical Rows",   3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Incline Rows",           "Incline Rows",    3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Horizontal Rows",        "Horizontal Rows", 3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Wide Rows",              "Wide Rows",       3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Weighted Inverted Rows", "Inverted Row",    3, minReps: 5, maxReps: 8, restMins: 1.5),

        bodyWeight("Vertical Pushup",       "Vertical Pushup",        3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Incline Pushup",        "Incline Pushup",         3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Full Pushup",           "Pushup",                 3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Diamond Pushup",        "Diamond Pushup",         3, minReps: 5, maxReps: 8, restMins: 1.5),
        bodyWeight("Psuedo Planche Pushup", "Pseudo Planche Pushups", 3, minReps: 5, maxReps: 8, restMins: 1.5),

        bodyWeight("Plank",                      "Front Plank",      1, minSecs: 10, maxSecs: 30),
        bodyWeight("Kneeling Ab Wheel Rollouts", "Ab Wheel Rollout", 3, minReps: 8, maxReps: 12, restMins: 1.5),
        bodyWeight("Standing Ab Wheel Rollouts", "Ab Wheel Rollout", 3, minReps: 8, maxReps: 12, restMins: 1.5),

        bodyWeight("Pallof Press",           "Pallof Press",           3, minReps: 8, maxReps: 12, restMins: 1.5),
        bodyWeight("Reverse Hyperextension", "Reverse Hyperextension", 3, minReps: 8, maxReps: 12, restMins: 1.5),
        ]
    
    makeProgression(exercises, "Split Squat warmup", "Bulgarian Split Squat warmup", "Beginner Shrimp Squat warmup", "Intermediate Shrimp Squat warmup", "Advanced Shrimp Squat warmup")
    makeProgression(exercises, "Split Squat", "Bulgarian Split Squat", "Beginner Shrimp Squat", "Intermediate Shrimp Squat", "Advanced Shrimp Squat", "Weighted Shrimp Squat")
    makeProgression(exercises, "Scapular Pulls", "Arch Hangs", "Negative Pullups", "Pullups", "Weighted Pullups")
    makeProgression(exercises, "Parallel Bar Support Hold", "Negative Dips", "Parallel Bar Dips", "Weighted Dips")
    makeProgression(exercises, "Romanian Deadlift", "Single-legged Deadlift", "Banded Negative Nordic Curl", "Banded Nordic Curl", "Nordic Curls")
    makeProgression(exercises, "Vertical Rows", "Incline Rows", "Horizontal Rows", "Wide Rows", "Weighted Inverted Rows")
    makeProgression(exercises, "Vertical Pushup", "Incline Pushup", "Full Pushup", "Diamond Pushup", "Psuedo Planche Pushup")
    makeProgression(exercises, "Plank", "Kneeling Ab Wheel Rollouts", "Standing Ab Wheel Rollouts")

    let workouts = [
        Workout("Warmup", ["Yuri's Shoulder Band", "Squat Sky Reaches", "GMB Wrist Prep", "Deadbugs", "Arch Hangs warmup", "Support Hold", "Split Squat warmup"], scheduled: false, optional: ["Arch Hangs warmup", "Support Hold", "Split Squat warmup"]),
        Workout("Workout", ["Scapular Pulls", "Split Squat", "Parallel Bar Support Hold", "Romanian Deadlift", "Vertical Rows", "Vertical Pushup", "Plank", "Pallof Press", "Reverse Hyperextension"], scheduled: true, optional: []),
    ]
    
    let tags: [Program.Tags] = [.beginner, .strength, .minimal, .unisex, .threeDays, .ageUnder40, .age40s, .age50s]
    let description = """
This is the recommended [program](https://www.reddit.com/r/bodyweightfitness/wiki/kb/recommended_routine) from the bodyweightfitness [reddit](https://www.reddit.com/r/bodyweightfitness). There should be one or two days of rest between each workout and it takes about an hour. Some equipment is required: a pullup bar, resistence bands, and a way to do dips.

**Warmup**
* Yuri's Shoulder Band 10 reps
* Squat Sky Reaches 10 reps
* GMB Wrist Prep 10+ reps
* Deadbugs 30s
* Arch Hangs 15 reps (add these once you reach Negative Pullups)
* Easier Squat Progression 10 reps (add this once you reach Bulgarian Split Squats)
* Easier Hinge Progression 10 reps (add this once you reach Banded Nordic Curls)

**Workout**
* Pullups 3x5-8
* Squat 3x5-8
* Dips 3x5-8
* Hinge 3x5-8
* Row 3x5-8
* Pushup 3x5-8
* Anti-extension 3x8-12
* Anti-rotation 3x8-12
* Extension 3x8-12

**Notes**
* To save time you can superset the exercises, e.g. do a set of pullups, rest 90s, do a set of squats, rest 90s, and repeat until you're finished with all the sets
* When doing reps aim for one rep short of failure.
* Once you can do all do all the reps with good form use the options screen to progress to a harder version of the exercise.
"""
    return Program("Reddit Bodyweight", workouts, exercises, tags, description)
}
