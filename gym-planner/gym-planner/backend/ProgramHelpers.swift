/// Helpers used when constructing programs.
import Foundation

/// CycleRepsPlan
public func barbell(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, warmups: Warmups? = nil, useBumpers: Bool = false, magnets: [Double] = [], restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets)
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = CycleRepsPlan(planName, warmups ?? defaultWarmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// LinearPlan
public func barbell(_ name: String, _ formalName: String, _ numSets: Int, by: Int, warmups: Warmups? = nil, useBumpers: Bool = false, magnets: [Double] = [], restMins: Double, planName: String = "", afterExercise: String? = nil) -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(by)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets)
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = LinearPlan(planName, warmups ?? defaultWarmups, workSets: numSets, workReps: by, afterExercise: afterExercise)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// AMRAPPlan
public func barbell(_ name: String, _ formalName: String, _ numSets: Int, amrap: Int, warmups: Warmups? = nil, useBumpers: Bool = false, magnets: [Double] = [], restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(amrap)+"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets)
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = AMRAPPlan(planName, warmups ?? defaultWarmups, workSets: numSets, workReps: amrap)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// PercentOfPlan
public func barbell(_ name: String, _ formalName: String, _ numSets: Int, by: Int, percent: Double, of: String, warmups: Warmups? = nil, useBumpers: Bool = false, magnets: [Double] = [], restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(Int(100*percent))% of \(of)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let setting = DerivedWeightSetting(of, restSecs: Int(restMins*60.0))
    let plan = PercentOfPlan(planName, warmups ?? defaultWarmups, workSets: numSets, workReps: by, percent: percent)
    return Exercise(name, formalName, plan, .derivedWeight(setting))
}

/// FiveThreeOneBeginnerPlan
public func barbell531Beginner(_ name: String, _ formalName: String, withBar: Int = 2, useBumpers: Bool = false, magnets: [Double] = [], restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "531"
    }
    
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets)
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = FiveThreeOneBeginnerPlan(planName, withBar: withBar)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// FiveThreeOneLPPlan
public func barbell531LP(_ name: String, _ formalName: String, useBumpers: Bool = false, magnets: [Double] = [], restMins: Double, _ sets: [FiveThreeOneLPPlan.WorkSet], workSetPercent: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "531LP"
    }
    
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets)
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = FiveThreeOneLPPlan(planName, sets, workSetPercent: workSetPercent)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// PercentsOfPlan
public func barbellPercents(_ name: String, _ formalName: String, of: String, restMins: Double, _ sets: [PercentsOfPlan.WorkSet], workSetPercent: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "percents"
    }
    
    let setting = DerivedWeightSetting(of, restSecs: Int(restMins*60.0))
    let plan = PercentsOfPlan(name, sets, workSetPercent: workSetPercent)
    return Exercise(name, formalName, plan, .derivedWeight(setting))
}

/// CycleRepsPlan
public func singlePlates(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, warmups: Warmups? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.singlePlates(plates: defaultPlates())
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = CycleRepsPlan(planName, warmups ?? defaultWarmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// CycleRepsPlan
public func pairedPlates(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, warmups: Warmups? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.pairedPlates(plates: defaultPlates())
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = CycleRepsPlan(planName, warmups ?? defaultWarmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// LinearPlan
public func pairedPlates(_ name: String, _ formalName: String, _ numSets: Int, by: Int, warmups: Warmups? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(by)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.pairedPlates(plates: defaultPlates())
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = LinearPlan(planName, warmups ?? defaultWarmups, workSets: numSets, workReps: by)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// CycleRepsPlan
public func dumbbell(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, warmups: Warmups? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.dumbbells2(weights: defaultDumbbells(), magnets: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = CycleRepsPlan(planName, warmups ?? defaultWarmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// LinearPlan
public func dumbbell(_ name: String, _ formalName: String, _ numSets: Int, by: Int, warmups: Warmups? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(by)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.dumbbells2(weights: defaultDumbbells(), magnets: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = LinearPlan(planName, warmups ?? defaultWarmups, workSets: numSets, workReps: by)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// CycleRepsPlan
public func singleDumbbell(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, warmups: Warmups? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.dumbbells1(weights: defaultDumbbells(), magnets: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = CycleRepsPlan(planName, warmups ?? defaultWarmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// CycleRepsPlan
public func machine(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, warmups: Warmups? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.machine(range1: defaultMachine(), range2: zeroMachine(), extra: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = CycleRepsPlan(planName, warmups ?? defaultWarmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// LinearPlan
public func machine(_ name: String, _ formalName: String, _ numSets: Int, by: Int, warmups: Warmups? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(by)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])

    let apparatus = Apparatus.machine(range1: defaultMachine(), range2: zeroMachine(), extra: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    let plan = LinearPlan(planName, warmups ?? defaultWarmups, workSets: numSets, workReps: by)
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// FixedSetsPlan
public func bodyWeight(_ name: String, _ formalName: String, _ numSets: Int, by: Int, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(by)"
    }

    let setting = FixedWeightSetting(restSecs: Int(restMins*60.0))
    let plan = FixedSetsPlan(planName, numSets: numSets, numReps: by)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

/// TimedPlan
public func bodyWeight(_ name: String, _ formalName: String, _ numSets: Int, minSecs: Int, maxSecs: Int, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minSecs)-\(maxSecs)s"
    }
    
    let setting = FixedWeightSetting(restSecs: minSecs)
    let plan = TimedPlan(planName, numSets: numSets, targetTime: maxSecs)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

/// TimedPlan
public func bodyWeight(_ name: String, _ formalName: String, _ numSets: Int, secs: Int, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(secs)s"
    }
    
    let setting = FixedWeightSetting(restSecs: secs)
    let plan = TimedPlan(planName, numSets: numSets, targetTime: secs)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

/// VariableRepsPlan
public func bodyWeight(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let setting = VariableRepsSetting(requestedReps: minReps, restSecs: Int(restMins*60.0))
    let plan = VariableRepsPlan(planName, numSets: numSets, minReps: minReps, maxReps: maxReps)
    return Exercise(name, formalName, plan, .variableReps(setting))
}

/// VariableSetsPlan
public func bodyWeight(_ name: String, _ formalName: String, requestedReps: Int, targetReps: Int, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = requestedReps != targetReps ? "\(requestedReps)-\(targetReps)" : "\(targetReps) reps"
    }
    
    let setting = VariableRepsSetting(requestedReps: requestedReps, restSecs: Int(restMins*60.0))
    let plan = VariableSetsPlan(planName, targetReps: targetReps)
    return Exercise(name, formalName, plan, .variableReps(setting))
}

public func hiit(_ name: String, warmupMins: Int, highSecs: Int, lowSecs: Int, cooldownMins: Int, numCycles: Int, targetCycles: Int? = nil, targetHighSecs: Int? = nil, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "HIIT"
    }
    
    let setting = HIITSetting(warmupMins: warmupMins, highSecs: highSecs, lowSecs: lowSecs, cooldownMins: cooldownMins, numCycles: numCycles)
    let plan = HIITPlan(planName, targetCycles: targetCycles ?? numCycles, targetHighSecs: targetHighSecs ?? highSecs)
    return Exercise(name, "HIIT", plan, .hiit(setting))
}

public func makeProgression(_ exercises: [Exercise], _ names: String...) {
    func setNext(_ name: String, _ other: String) {
        let exercise = exercises.first {$0.name == name}!
        exercise.nextExercise = other
    }
    
    func setPrev(_ name: String, _ other: String) {
        let exercise = exercises.first {$0.name == name}!
        exercise.prevExercise = other
    }
    
    for (i, name) in names.enumerated() {
        if i > 0 {
            setNext(names[i-1], name)
            setPrev(name, names[i-1])
        }
    }
}

