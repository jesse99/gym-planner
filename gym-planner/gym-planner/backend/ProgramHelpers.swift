/// Helpers used when constructing programs.
import Foundation

public func barbell(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, warmups: Warmups? = nil, useBumpers: Bool = false, magnets: [Double] = [], derivedFrom: String? = nil, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let defaultWarmups = Warmups(withBar: 0, firstPercent: 0.8, lastPercent: 0.8, reps: [])
    
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets)
    if let otherName = derivedFrom {
        let setting = DerivedWeightSetting(otherName, restSecs: Int(restMins*60.0))
        let plan = CycleRepsPlan(planName, warmups ?? defaultWarmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
        return Exercise(name, formalName, plan, .derivedWeight(setting))
        
    } else {
        let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
        let plan = CycleRepsPlan(planName, warmups ?? defaultWarmups, numSets: numSets, minReps: minReps, maxReps: maxReps)
        return Exercise(name, formalName, plan, .variableWeight(setting))
    }
}

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

public func bodyWeight(_ name: String, _ formalName: String, _ numSets: Int, by: Int, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(by)"
    }

    let setting = FixedWeightSetting(restSecs: Int(restMins*60.0))
    let plan = FixedSetsPlan(planName, numSets: numSets, numReps: by)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func bodyWeight(_ name: String, _ formalName: String, _ numSets: Int, minSecs: Int, maxSecs: Int, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minSecs)-\(maxSecs)s"
    }
    
    let setting = FixedWeightSetting(restSecs: minSecs)
    let plan = TimedPlan(planName, numSets: numSets, targetTime: maxSecs)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func bodyWeight(_ name: String, _ formalName: String, _ numSets: Int, secs: Int, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(secs)s"
    }
    
    let setting = FixedWeightSetting(restSecs: secs)
    let plan = TimedPlan(planName, numSets: numSets, targetTime: secs)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func bodyWeight(_ name: String, _ formalName: String, _ numSets: Int, minReps: Int, maxReps: Int, restMins: Double, planName: String = "") -> Exercise {
    var planName = planName
    if planName == "" {
        planName = "\(numSets)x\(minReps)-\(maxReps)"
    }
    
    let setting = VariableRepsSetting(requestedReps: minReps, restSecs: Int(restMins*60.0))
    let plan = VariableRepsPlan(planName, numSets: numSets, minReps: minReps, maxReps: maxReps)
    return Exercise(name, formalName, plan, .variableReps(setting))
}

// -------------------------------------------------------------------------------------


public func createSinglePlates(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.singlePlates(plates: defaultPlates())
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

public func createDumbbell1(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.dumbbells1(weights: defaultDumbbells(), magnets: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

public func createKettlebell(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let setting = FixedWeightSetting(restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

/// Helper used when constructing programs.
public func createVarSets(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, requestedReps: Int) -> Exercise {
    let setting = VariableRepsSetting(requestedReps: requestedReps, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableReps(setting))
}

public func createCycleReps(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.machine(range1: defaultMachine(), range2: zeroMachine(), extra: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

public func createCardio(_ name: String, _ plan: Plan) -> Exercise {
    let setting = IntensitySetting()
    return Exercise(name, "", plan, .intensity(setting))
}

public func createHIIT(_ name: String, _ plan: Plan) -> Exercise {
    let setting = HIITSetting(warmupMins: 5, highSecs: 30, lowSecs: 60, cooldownMins: 5, numCycles: 4)
    return Exercise(name, "", plan, .hiit(setting))
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

