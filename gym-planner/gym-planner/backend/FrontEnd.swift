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

public func findVariableRepsSetting(_ name: String) -> Either<String, VariableRepsSetting> {
    if let exercise = frontend.findExercise(name) {
        if case let .variableReps(setting) = exercise.settings {
            return .right(setting)
        } else {
            return .left("Exercise '\(name)' isn't using variable reps")
        }
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}

public func findWeight(_ name: String) -> Either<String, Double> {
    if let exercise = frontend.findExercise(name) {
        switch exercise.settings {
        case .variableWeight(let setting): return .right(setting.weight)
        case .derivedWeight(let setting): return findWeight(setting.otherName)
        case .fixedWeight(let setting): return .right(setting.weight)
        case .variableReps(let setting): return .right(setting.weight)
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
        case .variableReps(let setting): return .right(setting.restSecs)
        }
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}

public func findApparatus(_ name: String) -> Either<String, Apparatus> {
    if let exercise = frontend.findExercise(name) {
        switch exercise.settings {
        case .variableWeight(let setting): return .right(setting.apparatus)
        case .derivedWeight(let setting): return findApparatus(setting.otherName)
        default: return .left("Exercise '\(name)' is using fixed weight not variable or derived weight")
        }
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}

/// If the exercise depends upon another exercise (e.g. for DerivedWeightSetting)
/// then return the other exercise's name. Otherwise return self.name.
public func findBaseExerciseName(_ name: String) -> Either<String, String> {
    if let exercise = frontend.findExercise(name) {
        switch exercise.settings {
        case .derivedWeight(let setting): return name != setting.otherName ? findBaseExerciseName(setting.otherName) : .left("Derived exercise name is itself: '\(name)'")  // TODO: UI should make sure otherName can't be name
        default: return .right(name)
        }
    } else {
        return .left("Couldn't find exercise '\(name)'")
    }
}

