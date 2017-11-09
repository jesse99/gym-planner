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

public class Exercise {
    init(_ name: String, _ apparatus: Apparatus) {
        self.name = name
        self.apparatus = apparatus
    }
    
    public let name: String
    public let apparatus: Apparatus?    // most exercises have an apparatus, but stuff like cardio doesn't
}
