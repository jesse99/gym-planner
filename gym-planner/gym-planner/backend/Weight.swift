/// Types used to manage weights.
import Foundation

public enum Apparatus
{
    case barbell(bar: Double, plates: [Double], bumpers: [Double], magnets: [Double])

    /// Extra is an arbitrary optional weight that can be added, e.g. for weighted pullups.
    case bodyWeight(extra: Double)

//    case dumbbells(weights: [Double], magnets: [Double])
//
//    /// Used for stuff like cable machines with a stack of plates. Extra are small weights that can be optionally added.
//    case machine(weights: [Double], extra: [Double])
//
//    /// Used with plates attached to a machine two at a time (e.g. a Leg Press machine).
//    case pairedPlates(plates: [Double])
//
//    /// Used with plates attached to a machine one at a time (e.g. a T Bar Row machine).
//    case singlePlates(plates: [Double])
}

public class Exercise {
    init(_ name: String, _ apparatus: Apparatus) {
        self.name = name
        self.apparatus = apparatus
    }
    
    public let name: String
    public let apparatus: Apparatus?    // most exercises have an apparatus, but stuff like cardio doesn't
}

// TODO:
// text
// plates
// apply percent
// units
internal struct Weight: CustomStringConvertible {
    enum Direction {
        case lower
        case closest
        case upper
    }
    
    init(_ weight: Double) {
        self.weight = weight
    }
    
    /// Returns a string like "135 lbs". The to argument is a hint, e.g. if lower is used the result will
    /// normally be less than weight but can be greater if it's not possible to use a lower weight.
    func text(_ to: Direction, _ exercise: Exercise) -> String {
        return ""
    }
    
    var description: String {
        return String(format: ".3f", weight)
    }
    
    private let weight: Double
}

private func weightToStr(_ settings: Data, _ weight: Double) -> String {
    return String(format: "%.1f", weight) + " lbs"   // TODO: needs to use plates and units
}

