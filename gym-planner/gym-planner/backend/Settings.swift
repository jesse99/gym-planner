/// Exercise configuration that users are expected to change.
import Foundation

public enum Apparatus
{
    case barbell(bar: Double, collar: Double, plates: [(Int, Double)], bumpers: [(Int, Double)], magnets: [Double], warmupsWithBar: Int)
    
    case dumbbells(weights: [Double], magnets: [Double])
    //
    //    /// Used for stuff like cable machines with a stack of plates. Extra are small weights that can be optionally added.
    //    case machine(weights: [Double], extra: [Double])
    //
    //    /// Used with plates attached to a machine two at a time (e.g. a Leg Press machine).
    //    case pairedPlates(plates: [(Int, Double)])
    //
    //    /// Used with plates attached to a machine one at a time (e.g. a T Bar Row machine).
    //    case singlePlates(plates: [(Int, Double)])
}

/// Used for exercises that use plates, or dumbbells, or machines with variable weights.
public class VariableWeightSetting {
    var apparatus: Apparatus
    var weight: Double  // starts out at 0.0
    var restSecs: Int
    
    init(_ apparatus: Apparatus, restSecs: Int) {
        self.apparatus = apparatus
        self.weight = 0.0
        self.restSecs = restSecs
    }
}

/// Used for exercises where the user controls how much weight is used (which can be
/// zero for a body weight exercise).
public class FixedWeightSetting {
    var weight: Double  // starts out at 0.0
    var restSecs: Int
    
    init(restSecs: Int) {
        self.weight = 0.0
        self.restSecs = restSecs
    }
}

public enum Settings {
    case variableWeight(setting: VariableWeightSetting)
    case fixedWeight(setting: FixedWeightSetting)
}

// TODO: CardioSetting

