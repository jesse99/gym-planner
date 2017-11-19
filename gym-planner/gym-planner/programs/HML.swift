/// Masters program with cycles
import Foundation

func HML() -> Program {
    // exercises
    func squat() -> Exercise {
        let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: [], magnets: [], warmupsWithBar: 4)
        let setting = VariableWeightSetting(apparatus, restSecs: 3*60)
        return Exercise("Squat", "Low bar Squat", "531", .variableWeight(setting))
    }
    
    func bench() -> Exercise {
        let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: [], magnets: [], warmupsWithBar: 2)
        let setting = VariableWeightSetting(apparatus, restSecs: 3*60)
        return Exercise("Bench Press", "Bench Press", "531", .variableWeight(setting))
    }
    
    func dead() -> Exercise {
        let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: [], magnets: [], warmupsWithBar: 2)
        let setting = VariableWeightSetting(apparatus, restSecs: 3*60 + 30)
        return Exercise("Deadlift", "Deadlift", "Dead", .variableWeight(setting))
    }
    
    func lightSquat() -> Exercise {
        let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: [], magnets: [], warmupsWithBar: 4)
        let setting = VariableWeightSetting(apparatus, restSecs: 2*60)
        return Exercise("Light Squat", "Low bar Squat", "Light Squat", .variableWeight(setting))
    }
    
    func ohp() -> Exercise {
        let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: [], magnets: [], warmupsWithBar: 2)
        let setting = VariableWeightSetting(apparatus, restSecs: 3*60)
        return Exercise("Overhead Press", "Overhead Press", "53", .variableWeight(setting))
    }
    
    func chinups() -> Exercise {
        let setting = FixedWeightSetting(restSecs: 2*60)
        return Exercise("Chinups", "Chinup", "Chins", .fixedWeight(setting))
    }
    
    func mediumSquat() -> Exercise {
        let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: [], magnets: [], warmupsWithBar: 4)
        let setting = VariableWeightSetting(apparatus, restSecs: 3*60)
        return Exercise("Medium Squat", "Low bar Squat", "Medium Squat", .variableWeight(setting))
    }
    
    func mediumBench() -> Exercise {
        let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: [], magnets: [], warmupsWithBar: 2)
        let setting = VariableWeightSetting(apparatus, restSecs: 3*60)
        return Exercise("Medium Bench", "Bench Press", "Medium Bench", .variableWeight(setting))
    }
    
    // plans
    func fiveThreeOnePlan() -> Plan {
        let fives  = MastersBasicCyclePlan.Execute(workSets: 3, workReps: 5, percent: 1.0)
        let threes = MastersBasicCyclePlan.Execute(workSets: 3, workReps: 3, percent: 1.05)
        let ones   = MastersBasicCyclePlan.Execute(workSets: 3, workReps: 1, percent: 1.1)
        return MastersBasicCyclePlan("531", [fives, threes, ones])
    }
    
    func fiveThreePlan() -> Plan {
        let fives  = MastersBasicCyclePlan.Execute(workSets: 3, workReps: 5, percent: 1.0)
        let threes = MastersBasicCyclePlan.Execute(workSets: 3, workReps: 3, percent: 1.055)
        return MastersBasicCyclePlan("53", [fives, threes])
    }
    
    func deadPlan() -> Plan {
        let fives  = MastersBasicCyclePlan.Execute(workSets: 1, workReps: 5, percent: 1.0)
        let threes = MastersBasicCyclePlan.Execute(workSets: 1, workReps: 3, percent: 1.05)
        let ones   = MastersBasicCyclePlan.Execute(workSets: 1, workReps: 1, percent: 1.1)
        return MastersBasicCyclePlan("Dead", [fives, threes, ones])
    }
    
    func lightSquatPlan() -> Plan {
        return PercentOfPlan("Light Squat", "Squat", firstWarmupPercent: 0.5, warmupReps: [5, 3, 1, 1], workSets: 1, workReps: 5, percent: 0.88)
    }
    
    func mediumSquatPlan() -> Plan {
        return PercentOfPlan("Medium Squat", "Squat", firstWarmupPercent: 0.5, warmupReps: [5, 3, 1, 1, 1], workSets: 2, workReps: 5, percent: 0.94)
    }
    
    func mediumBenchPlan() -> Plan {
        return PercentOfPlan("Medium Bench", "Bench Press", firstWarmupPercent: 0.5, warmupReps: [5, 3, 1, 1, 1], workSets: 2, workReps: 5, percent: 0.94)
    }
    
    func chinsPlan() -> Plan {
        return VariableSetsPlan("Chins", requiredReps: 10, targetReps: 30)
    }
    
    // workouts
    func heavyDay() -> Workout {
        return Workout("Heavy Day", ["Squat", "Bench Press", "Deadlift"], optional: [])
    }
    
    func mediumDay() -> Workout {
        return Workout("Heavy Day", ["Medium Squat", "Medium Bench", "Chinups"], optional: [])
    }
    
    func lightDay() -> Workout {
        return Workout("Light Day", ["Light Squat", "Overhead Press", "Chinups"], optional: [])
    }
    
    // TODO: instead of using functions just use inline code and append onto the arrays (could use a helper for Execute)
    let exercises = [squat(), bench(), dead(), lightSquat(), ohp(), chinups(), mediumSquat(), mediumBench()]
    let plans = [fiveThreeOnePlan(), fiveThreePlan(), deadPlan(), lightSquatPlan(), mediumSquatPlan(), mediumBenchPlan(), chinsPlan()]
    let workouts = [heavyDay(), mediumDay(), lightDay()]
    let tags: [Program.Tags] = [.intermediate, .strength, .age40s, .age50s]
    let description = """
xxx
"""
    return Program("HML", workouts, exercises, plans, tags, description)
}
