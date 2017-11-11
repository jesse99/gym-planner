/// Types representing a routine within a workout.
import Foundation

public enum Apparatus
{
    case barbell(bar: Double, collar: Double, plates: [(Int, Double)], bumpers: [(Int, Double)], magnets: [Double])
    
    /// Extra is an arbitrary optional weight that can be added, e.g. for weighted pullups.
    case bodyWeight(extra: Double)
    
    //    case dumbbells(weights: [Double], magnets: [Double])
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

public enum Modality {
    case weights(apparatus: Apparatus, restSecs: Int, weight: Double)
//    case cardio(daysPerWeek: Int, minsPerDay: Int, rolloverMins: Int)
    case timed(numSets: Int, secs: Int, restSecs: Int)
}

public class Exercise {
    init(_ name: String, _ formalName: String, _ modality: Modality) {
        self.name = name
        self.formalName = formalName
        self.modality = modality
    }
    
    public let name: String             // "Heavy Bench"
    public let formalName: String       // "Bench Press"
    public let modality: Modality
}
