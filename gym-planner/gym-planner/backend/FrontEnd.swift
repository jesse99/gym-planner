import Foundation

/// Protocol used to communicate with the front end.
public protocol FrontEnd {
    func saveExercise(_ name: String)

    func findExercise(_ name: String) -> Exercise?

    func assert(_ predicate: Bool, _ message: String)
}

public var frontend: FrontEnd!

public func findExercise(_ name: String) -> Either<String, Exercise> {
    if let exercise = frontend.findExercise(name) {
        return .right(exercise)
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}

// It'd be nicer if plans could cache this off in their start methods but that's problematic
// when view restoration kicks in because we'd wind up with two instances of the settings.
public func findVariableWeightSetting(_ name: String) -> Either<String, VariableWeightSetting> {
    if let exercise = frontend.findExercise(name) {
        if case let .variableWeight(setting) = exercise.settings {
            return .right(setting)
        } else {
            return .left("Exercise '\(name)' isn't using variable weight")
        }
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}

public func findWeight(_ name: String) -> Either<String, Double> {
    if let exercise = frontend.findExercise(name) {
        switch exercise.settings {
        case .variableWeight(let setting): return .right(setting.weight)
        case .derivedWeight(_): return .left("Exercise '\(name)' uses a derived weight")
        case .fixedWeight(let setting): return .right(setting.weight)
        }
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}

public func findRestSecs(_ name: String) -> Either<String, Int> {
    if let exercise = frontend.findExercise(name) {
        switch exercise.settings {
        case .variableWeight(let setting): return .right(setting.restSecs)
        case .derivedWeight(let setting): return .right(setting.restSecs)
        case .fixedWeight(let setting): return .right(setting.restSecs)
        }
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}

public func findApparatus(_ name: String) -> Either<String, Apparatus> {
    if let exercise = frontend.findExercise(name) {
        switch exercise.settings {
        case .variableWeight(let setting): return .right(setting.apparatus)
        case .derivedWeight(let setting): return .right(setting.apparatus)
        case .fixedWeight(_): return .left("Exercise '\(name)' is using fixed weight not variable or derived weight")
        }
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}





