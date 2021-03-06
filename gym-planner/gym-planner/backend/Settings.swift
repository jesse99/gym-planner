/// Exercise configuration that users are expected to change.
import Foundation

public enum Settings {
    case variableWeight(VariableWeightSetting)
    case derivedWeight(DerivedWeightSetting)
    case fixedWeight(FixedWeightSetting)
    case variableReps(VariableRepsSetting)
    case intensity(IntensitySetting)
    case hiit(HIITSetting)
}

public struct MachineRange {
    public let min: Double
    public let max: Double
    public let step: Double
}

public enum Apparatus
{
    case barbell(bar: Double, collar: Double, plates: [Double], bumpers: [Double], magnets: [Double])
    
    /// Single dumbbell.
    case dumbbells1(weights: [Double], magnets: [Double])
    
    /// Paired dumbbells.
    case dumbbells2(weights: [Double], magnets: [Double])
    
    /// Used for stuff like cable machines with a stack of plates. Range2 is for machines that have weights like [5, 10, 15, 20, 30, ...]. Extra are small weights that can be optionally added.
    case machine(range1: MachineRange, range2: MachineRange, extra: [Double])
    
    /// Used with plates attached to a machine two at a time (e.g. a Leg Press machine).
    case pairedPlates(plates: [Double])
    
    /// Used with plates attached to a machine one at a time (e.g. a T-Bar Row machine).
    case singlePlates(plates: [Double])
}

/// Used for exercises that use plates, or dumbbells, or machines with variable weights.
public class VariableWeightSetting: Storable {
    var apparatus: Apparatus
    private(set) var weight: Double         // starts out at 0.0
    private(set) var updatedWeight: Date    // last time the weight was set, to either a new value or the same value and by the user or the app
    private(set) var userUpdated: Date      // time the user changed the weight
    var restSecs: Int
    var stalls: Int
    var reps: Int?

    init(_ apparatus: Apparatus, restSecs: Int, reps: Int? = nil) {
        self.apparatus = apparatus
        self.weight = 0.0
        self.updatedWeight = Date()
        self.userUpdated = Date.distantPast
        self.restSecs = restSecs
        self.stalls = 0
        self.reps = reps
    }
    
    public func errors() -> [String] {
        var problems: [String] = []
        
        problems += apparatus.errors()
        
        if weight < 0 {
            problems += ["setting.weight is less than 0"]
        }
        if restSecs < 0 {
            problems += ["setting,restSecs is less than 0"]
        }
        if stalls < 0 {
            problems += ["setting,stalls is less than 0"]
        }
        if let r = reps, r < 0 {
            problems += ["setting,reps is less than 0"]
        }
        
        return problems
    }
    
    public required init(from store: Store) {
        self.apparatus = store.getObj("apparatus")
        self.weight = store.getDbl("weight")
        self.updatedWeight = store.getDate("updatedWeight")
        self.userUpdated = store.getDate("userUpdated", ifMissing: Date.distantPast)
        self.restSecs = store.getInt("restSecs")
        self.stalls = store.getInt("stalls")

        let r = store.getInt("reps", ifMissing: 0)
        self.reps = r != 0 ? r : nil
    }
    
    public func save(_ store: Store) {
        store.addObj("apparatus", apparatus)
        store.addDbl("weight", weight)
        store.addDate("updatedWeight", updatedWeight)
        store.addDate("userUpdated", userUpdated)
        store.addInt("restSecs", restSecs)
        store.addInt("stalls", stalls)
        store.addInt("reps", reps ?? 0)
    }
    
    func changeWeight(_ weight: Double, byUser: Bool) {
        self.weight = weight;
        self.updatedWeight = Date()
        if byUser {
            self.userUpdated = Date()
        }
    }
    
    /// Used to indicate that an exercise was done even though the weight didn't actually change
    /// (so that we don't deload for time if the user is stalling).
    func sameWeight() {
        self.updatedWeight = Date()
    }
    
    /// This is used to help test deloadByTime.
    func forceDate(_ date: Date) {
        self.updatedWeight = date
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
    
    public func errors(_ program: Program) -> [String] {
        var problems: [String] = []
        
        if program.findExercise(otherName) == nil {
            problems += ["setting,otherName (\(otherName)) isn't defined"]
        }
        
        return problems
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
    
    public func errors() -> [String] {
        var problems: [String] = []
        
        if weight < 0 {
            problems += ["setting.weight is less than 0"]
        }
        if restSecs < 0 {
            problems += ["setting,restSecs is less than 0"]
        }
        if requestedReps < 0 {
            problems += ["setting,requestedReps is less than 0"]
        }
        
        return problems
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
    
    public func errors() -> [String] {
        var problems: [String] = []
        
        if weight < 0 {
            problems += ["setting.weight is less than 0"]
        }
        if restSecs < 0 {
            problems += ["setting,restSecs is less than 0"]
        }
        
        return problems
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
    
    public func errors() -> [String] {
        return []
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
    
    public func errors() -> [String] {
        var problems: [String] = []
        
        if warmupSecs < 0 {
            problems += ["setting.warmupSecs is less than 0"]
        }
        if highSecs < 0 {
            problems += ["setting,highSecs is less than 0"]
        }
        if lowSecs < 0 {
            problems += ["setting,lowSecs is less than 0"]
        }
        if cooldownSecs < 0 {
            problems += ["setting,cooldownSecs is less than 0"]
        }
        if numCycles < 1 {
            problems += ["setting,numCycles is less than 1"]
        }
        
        return problems
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

extension Apparatus {
    public func errors() -> [String] {
        var problems: [String] = []
        
        switch self {
        case .barbell(bar: let bar, collar: let collar, plates: let plates, bumpers: let bumpers, magnets: let magnets):
            if bar < 0 {
                problems += ["barbell.bar is less than 0"]
            }
            if collar < 0 {
                problems += ["barbell.collar is less than 0"]
            }
            if plates.isEmpty {
                problems += ["barbell.plates is empty"]
            }
            if plates.any({$0 < 0.0}) {
                problems += ["barbell.plates is less than 0"]
            }
            if bumpers.any({$0 < 0.0}) {
                problems += ["barbell.bumpers is less than 0"]
            }
            if magnets.any({$0 < 0.0}) {
                problems += ["barbell.magnets is less than 0"]
            }
            
        case .pairedPlates(plates: let plates):
            if plates.isEmpty {
                problems += ["pairedPlates.plates is empty"]
            }
            if plates.any({$0 < 0.0}) {
                problems += ["pairedPlates.plates is less than 0"]
            }
            
        case .singlePlates(plates: let plates):
            if plates.isEmpty {
                problems += ["singlePlates.plates is empty"]
            }
            if plates.any({$0 < 0.0}) {
                problems += ["singlePlates.plates is less than 0"]
            }
            
        case .dumbbells1(weights: let weights, magnets: let magnets):
            if weights.isEmpty {
                problems += ["dumbbells.weights is empty"]
            }
            if weights.any({$0 < 0.0}) {
                problems += ["dumbbells.weights is less than 0"]
            }
            if magnets.any({$0 < 0.0}) {
                problems += ["dumbbells.magnets is less than 0"]
            }
            
        case .dumbbells2(weights: let weights, magnets: let magnets):
            if weights.isEmpty {
                problems += ["dumbbells1.weights is empty"]
            }
            if weights.any({$0 < 0.0}) {
                problems += ["dumbbells1.weights is less than 0"]
            }
            if magnets.any({$0 < 0.0}) {
                problems += ["dumbbells1.magnets is less than 0"]
            }
            
        case .machine(let range1, let range2, let extra):
            problems += range1.errors("range1")
            
            if range2.min > 0 || range2.max > 0 {
                problems += range2.errors("range2")
            }
            
            if extra.any({$0 < 0.0}) {
                problems += ["machine.extra.weights is less than 0"]
            }
        }
        
        return problems
    }
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
            self = .barbell(bar: bar, collar: collar, plates: plates, bumpers: bumpers, magnets: magnets)
            
        case "paired-plates":
            let plates = store.getDblArray("plates", ifMissing: defaultPlates())
            self = .pairedPlates(plates: plates)
            
        case "single-plates":
            let plates = store.getDblArray("plates", ifMissing: defaultPlates())
            self = .singlePlates(plates: plates)
            
        case "dumbbells":
            let weights = store.getDblArray("weights")
            let magnets = store.getDblArray("magnets")
            self = .dumbbells2(weights: weights, magnets: magnets)
            
        case "dumbbells1":
            let weights = store.getDblArray("weights")
            let magnets = store.getDblArray("magnets")
            self = .dumbbells1(weights: weights, magnets: magnets)
            
        case "machine":
            let min1 = store.getDbl("min1")
            let max1 = store.getDbl("max1")
            let step1 = store.getDbl("step1")
            let range1 = MachineRange(min: min1, max: max1, step: step1)

            let min2 = store.getDbl("min2")
            let max2 = store.getDbl("max2")
            let step2 = store.getDbl("step2")
            let range2 = MachineRange(min: min2, max: max2, step: step2)

            let extra = store.getDblArray("extra")
            self = .machine(range1: range1, range2: range2, extra: extra)
            
        default:
            frontend.assert(false, "loading apparatus had unknown type: \(tname)"); abort()
        }
    }
    
    public func save(_ store: Store) {
        switch self {
        case .barbell(bar: let bar, collar: let collar, plates: let plates, bumpers: let bumpers, magnets: let magnets):
            store.addStr("type", "barbell")
            store.addDbl("bar", bar)
            store.addDbl("collar", collar)
            store.addDblArray("plates", plates)
            store.addDblArray("bumpers", bumpers)
            store.addDblArray("magnets", magnets)
            
        case .pairedPlates(plates: let plates):
            store.addStr("type", "paired-plates")
            store.addDblArray("plates", plates)
            
        case .singlePlates(plates: let plates):
            store.addStr("type", "single-plates")
            store.addDblArray("plates", plates)

        case .dumbbells1(weights: let weights, magnets: let magnets):
            store.addStr("type", "dumbbells1")
            store.addDblArray("weights", weights)
            store.addDblArray("magnets", magnets)
            
        case .dumbbells2(weights: let weights, magnets: let magnets):
            store.addStr("type", "dumbbells")
            store.addDblArray("weights", weights)
            store.addDblArray("magnets", magnets)
            
        case .machine(let range1, let range2, let extra):
            store.addStr("type", "machine")
            store.addDbl("min1", range1.min)
            store.addDbl("max1", range1.max)
            store.addDbl("step1", range1.step)

            store.addDbl("min2", range2.min)
            store.addDbl("max2", range2.max)
            store.addDbl("step2", range2.step)

            store.addDblArray("extra", extra)
        }
    }
}

extension MachineRange {
    public func errors(_ prefix: String) -> [String] {
        var problems: [String] = []
        
        if self.min < 1 {
            problems += ["\(prefix) min is less than 1"]
        }
        if self.max < 1 {
            problems += ["\(prefix) max is less than 1"]
        }
        if self.step < 0.1 {
            problems += ["\(prefix) step is less than 0.1"]
        }
        
        if self.min > self.max {
            problems += ["\(prefix) min is greater than max"]
        }

        return problems
    }
}

