import Foundation

/// Protocol used to communicate with the front end.
public protocol FrontEnd {
    func saveExercise(_ name: String)

    func findExercise(_ name: String) -> Exercise?
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
public func findSetting(_ name: String) -> Either<String, VariableWeightSetting> {
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



