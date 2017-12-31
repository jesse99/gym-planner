/// Exercise configuration that users are expected to change.
import Foundation

public enum Apparatus
{
    case barbell(bar: Double, collar: Double, plates: [Double], bumpers: [Double], magnets: [Double], warmupsWithBar: Int)
    
    case dumbbells(weights: [Double], magnets: [Double])
    //
    //    /// Used for stuff like cable machines with a stack of plates. Extra are small weights that can be optionally added.
    //    case machine(weights: [Double], extra: [Double])
    //
    //    /// Used with plates attached to a machine two at a time (e.g. a Leg Press machine).
    //    case pairedPlates(plates: [Double])
    //
    //    /// Used with plates attached to a machine one at a time (e.g. a T-Bar Row machine).
    //    case singlePlates(plates: [Double])
}

/// Used for exercises that use plates, or dumbbells, or machines with variable weights.
public class VariableWeightSetting: Storable {
    var apparatus: Apparatus
    private(set) var weight: Double  // starts out at 0.0
    private(set) var updatedWeight: Date    // last time the weight was set, to either a new value or the same value and by the user or the app
    var restSecs: Int
    var stalls: Int
    var reps: Int?

    init(_ apparatus: Apparatus, restSecs: Int, reps: Int? = nil) {
        self.apparatus = apparatus
        self.weight = 0.0
        self.updatedWeight = Date()
        self.restSecs = restSecs
        self.stalls = 0
        self.reps = reps
    }
    
    public required init(from store: Store) {
        self.apparatus = store.getObj("apparatus")
        self.weight = store.getDbl("weight")
        self.updatedWeight = store.getDate("updatedWeight")
        self.restSecs = store.getInt("restSecs")
        self.stalls = store.getInt("stalls")

        let r = store.getInt("reps", ifMissing: 0)
        self.reps = r != 0 ? r : nil
    }
    
    public func save(_ store: Store) {
        store.addObj("apparatus", apparatus)
        store.addDbl("weight", weight)
        store.addDate("updatedWeight", updatedWeight)
        store.addInt("restSecs", restSecs)
        store.addInt("stalls", stalls)
        store.addInt("reps", reps ?? 0)
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
public class DerivedWeightSetting: Storable {
    var restSecs: Int
    
    /// The name of the exercise that this exercise depends upon. (This isn't really a setting because
    /// it's not something a user is expected to fiddle with from workout to workout but this is a
    /// convient spot to put it so that code can do things like find the apparatus the base exercise
    /// uses).
    var otherName: String
    
    init(_ otherName: String, restSecs: Int) {
        self.otherName = otherName
        self.restSecs = restSecs
    }
    
    public required init(from store: Store) {
        self.otherName = store.getStr("otherName")
        self.restSecs = store.getInt("restSecs")
    }
    
    public func save(_ store: Store) {
        store.addStr("otherName", otherName)
        store.addInt("restSecs", restSecs)
    }
}

/// Used with VariableSetsPlan.
public class VariableRepsSetting: Storable {
    var weight: Double  // starts out at 0.0
    var restSecs: Int
    
    /// Number of reps the user wants to do.
    var requestedReps: Int
    
    init(requestedReps: Int, restSecs: Int) {
        self.requestedReps = requestedReps
        self.weight = 0.0
        self.restSecs = restSecs
    }
    
    public required init(from store: Store) {
        self.requestedReps = store.getInt("requestedReps")
        self.weight = store.getDbl("weight")
        self.restSecs = store.getInt("restSecs")
    }
    
    public func save(_ store: Store) {
        store.addInt("requestedReps", requestedReps)
        store.addDbl("weight", weight)
        store.addInt("restSecs", restSecs)
    }
}

/// Used for exercises where the user controls how much weight is used (which can be
/// zero for a body weight exercise).
public class FixedWeightSetting: Storable {  
    var weight: Double  // starts out at 0.0
    var restSecs: Int
    
    init(restSecs: Int) {
        self.weight = 0.0
        self.restSecs = restSecs
    }
    
    public required init(from store: Store) {
        self.weight = store.getDbl("weight")
        self.restSecs = store.getInt("restSecs")
    }
    
    public func save(_ store: Store) {
        store.addDbl("weight", weight)
        store.addInt("restSecs", restSecs)
    }
}

/// Used by stuff like SteadyStateCardio.
public class IntensitySetting: Storable {
    /// Arbitrary tag. Can be empty.
    var intensity: String
    
    init(intensity: String = "") {
        self.intensity = intensity
    }
    
    public required init(from store: Store) {
        self.intensity = store.getStr("intensity")
    }
    
    public func save(_ store: Store) {
        store.addStr("intensity", intensity)
    }
}

public class HIITSetting: Storable {
    var warmupSecs: Int
    var highSecs: Int
    var lowSecs: Int
    var cooldownSecs: Int
    
    var numCycles: Int
    
    /// Arbitrary tags. Can be empty.
    var warmupIntensity: String
    var highIntensity: String
    var lowIntensity: String
    var cooldownIntensity: String
    
    init(warmupMins: Int, highSecs: Int, lowSecs: Int, cooldownMins: Int, numCycles: Int) {
        self.warmupSecs = 60*warmupMins
        self.highSecs = highSecs
        self.lowSecs = lowSecs
        self.cooldownSecs = 60*cooldownMins
        
        self.numCycles = numCycles
        
        self.warmupIntensity = ""
        self.highIntensity = ""
        self.lowIntensity = ""
        self.cooldownIntensity = ""
    }
    
    public required init(from store: Store) {
        self.warmupSecs = store.getInt("warmupSecs")
        self.highSecs = store.getInt("highSecs")
        self.lowSecs = store.getInt("lowSecs")
        self.cooldownSecs = store.getInt("cooldownSecs")

        self.numCycles = store.getInt("numCycles")

        self.warmupIntensity = store.getStr("warmupIntensity")
        self.highIntensity = store.getStr("highIntensity")
        self.lowIntensity = store.getStr("lowIntensity")
        self.cooldownIntensity = store.getStr("cooldownIntensity")
    }
    
    public func save(_ store: Store) {
        store.addInt("warmupSecs", warmupSecs)
        store.addInt("highSecs", highSecs)
        store.addInt("lowSecs", lowSecs)
        store.addInt("cooldownSecs", cooldownSecs)

        store.addInt("numCycles", numCycles)

        store.addStr("warmupIntensity", warmupIntensity)
        store.addStr("highIntensity", highIntensity)
        store.addStr("lowIntensity", lowIntensity)
        store.addStr("cooldownIntensity", cooldownIntensity)
    }
}

public enum Settings {
    case variableWeight(VariableWeightSetting)
    case derivedWeight(DerivedWeightSetting)
    case fixedWeight(FixedWeightSetting)
    case variableReps(VariableRepsSetting)
    case intensity(IntensitySetting)
    case hiit(HIITSetting)
}

extension Apparatus: Storable {
    public init(from store: Store) {
        let tname = store.getStr("type")
        switch tname {
        case "barbell":
            let bar = store.getDbl("bar")
            let collar = store.getDbl("collar")
            let plates = store.getDblArray("plates", ifMissing: defaultPlates())
            let bumpers = store.getDblArray("bumpers", ifMissing: defaultBumpers())
            let magnets = store.getDblArray("magnets")
            let warmupsWithBar = store.getInt("warmupsWithBar")
            self = .barbell(bar: bar, collar: collar, plates: plates, bumpers: bumpers, magnets: magnets, warmupsWithBar: warmupsWithBar)
            
        case "dumbbells":
            let weights = store.getDblArray("weights")
            let magnets = store.getDblArray("magnets")
            self = .dumbbells(weights: weights, magnets: magnets)
            
        default:
            frontend.assert(false, "loading apparatus had unknown type: \(tname)"); abort()
        }
    }
    
    public func save(_ store: Store) {
        switch self {
        case .barbell(bar: let bar, collar: let collar, plates: let plates, bumpers: let bumpers, magnets: let magnets, warmupsWithBar: let warmupsWithBar):
            store.addStr("type", "barbell")
            store.addDbl("bar", bar)
            store.addDbl("collar", collar)
            store.addDblArray("plates", plates)
            store.addDblArray("bumpers", bumpers)
            store.addDblArray("magnets", magnets)
            store.addInt("warmupsWithBar", warmupsWithBar)
            
        case .dumbbells(weights: let weights, magnets: let magnets):
            store.addStr("type", "dumbbells")
            store.addDblArray("weights", weights)
            store.addDblArray("magnets", magnets)
        }
    }
}

extension Settings: Storable {
    public init(from store: Store) {
        let tname = store.getStr("type")
        switch tname {
        case "variable":
            self = .variableWeight(store.getObj("setting"))
        case "derived":
            self = .derivedWeight(store.getObj("setting"))
        case "fixed":
            self = .fixedWeight(store.getObj("setting"))
        case "variableReps":
            self = .variableReps(store.getObj("setting"))
        case "timed":
            self = .fixedWeight(FixedWeightSetting(restSecs: 60))   // TODO: remove this
        case "intensity":
            self = .intensity(store.getObj("setting"))
        case "hiit":
            self = .hiit(store.getObj("setting"))
        default:
            frontend.assert(false, "loading settings had unknown type: \(tname)"); abort()
        }
    }
    
    public func save(_ store: Store) {
        switch self {
        case .variableWeight(let setting):
            store.addStr("type", "variable")
            store.addObj("setting", setting)
        case .derivedWeight(let setting):
            store.addStr("type", "derived")
            store.addObj("setting", setting)
        case .fixedWeight(let setting):
            store.addStr("type", "fixed")
            store.addObj("setting", setting)
        case .variableReps(let setting):
            store.addStr("type", "variableReps")
            store.addObj("setting", setting)
        case .intensity(let setting):
            store.addStr("type", "intensity")
            store.addObj("setting", setting)
        case .hiit(let setting):
            store.addStr("type", "hiit")
            store.addObj("setting", setting)
        }
    }
}
