/// Helpers used when constructing programs.
import Foundation

public func createBarBell(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, useBumpers: Bool = false, magnets: [Double] = [], derivedFrom: String? = nil) -> Exercise {
    let apparatus = Apparatus.barbell(bar: 45.0, collar: 0.0, plates: defaultPlates(), bumpers: useBumpers ? defaultBumpers() : [], magnets: magnets)
    if let otherName = derivedFrom {
        let setting = DerivedWeightSetting(otherName, restSecs: Int(restMins*60.0))
        return Exercise(name, formalName, plan, .derivedWeight(setting))
        
    } else {
        let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
        return Exercise(name, formalName, plan, .variableWeight(setting))
    }
}

public func createDumbbell1(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.dumbbells1(weights: defaultDumbbells(), magnets: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

public func createDumbbell2(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.dumbbells2(weights: defaultDumbbells(), magnets: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

public func createKettlebell(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let setting = FixedWeightSetting(restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func createMachine(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.machine(range1: defaultMachine(), range2: zeroMachine(), extra: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

/// Helper used when constructing programs.
public func createFixed(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let setting = FixedWeightSetting(restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .fixedWeight(setting))
}

public func createVarReps(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, requestedReps: Int) -> Exercise {
    let setting = VariableRepsSetting(requestedReps: requestedReps, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableReps(setting))
}

public func createVarSets(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double, requestedReps: Int) -> Exercise {
    let setting = VariableRepsSetting(requestedReps: requestedReps, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableReps(setting))
}

public func createCycleReps(_ name: String, _ formalName: String, _ plan: Plan, restMins: Double) -> Exercise {
    let apparatus = Apparatus.machine(range1: defaultMachine(), range2: zeroMachine(), extra: [])
    let setting = VariableWeightSetting(apparatus, restSecs: Int(restMins*60.0))
    return Exercise(name, formalName, plan, .variableWeight(setting))
}

public func createTimed(_ name: String, _ formalName: String, _ plan: Plan, duration: Int) -> Exercise {
    let setting = FixedWeightSetting(restSecs: duration)
    return Exercise(name, formalName, plan, .fixedWeight(setting))
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

