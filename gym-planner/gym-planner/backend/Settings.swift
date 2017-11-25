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
public class VariableWeightSetting: Codable {
    var apparatus: Apparatus
    private(set) var weight: Double  // starts out at 0.0
    private(set) var updatedWeight: Date
    var restSecs: Int
    var stalls: Int
    
    init(_ apparatus: Apparatus, restSecs: Int) {
        self.apparatus = apparatus
        self.weight = 0.0
        self.updatedWeight = Date()
        self.restSecs = restSecs
        self.stalls = 0
    }
    
    func changeWeight(_ weight: Double) {
        self.weight = weight;
        self.updatedWeight = Date()
    }
    
    /// Used to indicate that an exercise was done even though the weight didn't actually change
    /// (so that we don't deload for time if the user is stalling).
    func sameWeight() {
        self.updatedWeight = Date()
    }
}

/// Used for an exercise where the weight is derived from another exercises's VariableWeightSetting,
/// e.g. when PercentOfPlan is used.
public class DerivedWeightSetting: Codable {
    var apparatus: Apparatus
    var restSecs: Int
    
    init(_ apparatus: Apparatus, restSecs: Int) {
        self.apparatus = apparatus
        self.restSecs = restSecs
    }
}

/// Used for exercises where the user controls how much weight is used (which can be
/// zero for a body weight exercise).
public class FixedWeightSetting: Codable {
    var weight: Double  // starts out at 0.0
    var restSecs: Int
    
    init(restSecs: Int) {
        self.weight = 0.0
        self.restSecs = restSecs
    }
}

public enum Settings {
    case variableWeight(VariableWeightSetting)
    case derivedWeight(DerivedWeightSetting)
    case fixedWeight(FixedWeightSetting)
}

// TODO: CardioSetting

// Enums with associated values can't be directly archived so we need all this nonsense.
extension Apparatus: Codable {
    private enum CodingKeys: String, CodingKey {
        case base, barbellParams, dumbbellParams
    }
    
    private enum Base: String, Codable {
        case barbell, dumbbells
    }
    
    private struct BarbellParams: Codable {
        let bar: Double
        let collar: Double
        let plateCounts: [Int]
        let plateWeights: [Double]  // also can't archived tuples so we break apart the .barbell arrays
        let bumperCounts: [Int]
        let bumperWeights: [Double]
        let magnets: [Double]
        let warmupsWithBar: Int
        
        init(_ bar: Double, _ collar: Double, _ plates: [(Int, Double)], _ bumpers: [(Int, Double)], _ magnets: [Double], _ warmupsWithBar: Int) {
            self.bar = bar
            self.collar = collar
            self.plateCounts = plates.map {$0.0}
            self.plateWeights = plates.map {$0.1}
            self.bumperCounts = bumpers.map {$0.0}
            self.bumperWeights = bumpers.map {$0.1}
            self.magnets = magnets
            self.warmupsWithBar = warmupsWithBar
        }
    }
    
    private struct DumbbellParams: Codable {
        let weights: [Double]
        let magnets: [Double]
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .barbell:
            let p = try container.decode(BarbellParams.self, forKey: .barbellParams)
            let plates = Array(zip(p.plateCounts, p.plateWeights))
            let bumpers = Array(zip(p.bumperCounts, p.bumperWeights))
            self = .barbell(bar: p.bar, collar: p.collar, plates: plates, bumpers: bumpers, magnets: p.magnets, warmupsWithBar: p.warmupsWithBar)
        case .dumbbells:
            let p = try container.decode(DumbbellParams.self, forKey: .dumbbellParams)
            self = .dumbbells(weights: p.weights, magnets: p.magnets)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .barbell(bar: let bar, collar: let collar, plates: let plates, bumpers: let bumpers, magnets: let magnets, warmupsWithBar: let warmupsWithBar):
            try container.encode(Base.barbell, forKey: .base)
            try container.encode(BarbellParams(bar, collar, plates, bumpers, magnets, warmupsWithBar), forKey: .barbellParams)
        case .dumbbells(weights: let weights, magnets: let magnets):
            try container.encode(Base.dumbbells, forKey: .base)
            try container.encode(DumbbellParams(weights: weights, magnets: magnets), forKey: .dumbbellParams)
        }
    }
}

extension Settings: Codable {
    private enum CodingKeys: String, CodingKey {
        case base, varParams, derivedParams, fixedParams
    }
    
    private enum Base: String, Codable {
        case variable, derived, fixed
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .variable:
            let s = try container.decode(VariableWeightSetting.self, forKey: .varParams)
            self = .variableWeight(s)
        case .derived:
            let s = try container.decode(DerivedWeightSetting.self, forKey: .derivedParams)
            self = .derivedWeight(s)
        case .fixed:
            let s = try container.decode(FixedWeightSetting.self, forKey: .fixedParams)
            self = .fixedWeight(s)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .variableWeight(let setting):
            try container.encode(Base.variable, forKey: .base)
            try container.encode(setting, forKey: .varParams)
        case .derivedWeight(let setting):
            try container.encode(Base.derived, forKey: .base)
            try container.encode(setting, forKey: .derivedParams)
        case .fixedWeight(let setting):
            try container.encode(Base.fixed, forKey: .base)
            try container.encode(setting, forKey: .fixedParams)
        }
    }
}
