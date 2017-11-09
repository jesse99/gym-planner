/// Types used to manage weights.
import Foundation

protocol WeightGenerator
{
    func first() -> (Double, String)
    
    func next() -> (Double, String)?
}

// TODO:
// text
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
    
    // TODO: think we need settings after all
    func canFind(_ exercise: Exercise) -> Bool {
        switch exercise.apparatus! {
        case .barbell(bar: _, collar: _, plates: let plates, bumpers: let bumpers, magnets: _):
            return !plates.isEmpty || !bumpers.isEmpty
        default:
            assert(false)   // TODO: get rid of this once we handle all the cases
        }
    }
    
    /// Returns something like (145.0, "145 lbs", "45 + 5". Note that if the direction constraint
    /// can't be satisfied this will return something as close as possible, e.g. doing a find using
    /// a weight below the smallest dumbbell will return the smallest dumbbell.
    func find(_ to: Direction, _ exercise: Exercise) -> (weight: Double, text: String, plates: String) {
        assert(exercise.apparatus != nil, "need an apparatus to infer a weight")
        assert(canFind(exercise))
        
        let (lowerWeight, lowerPlates, closestWeight, closestPlates, upperWeight, upperPlates) = findRange(exercise)
        switch to {
        case .lower: return (weight: lowerWeight, text: "\(Weight.friendlyStr(lowerWeight)) lbs", plates: lowerPlates)
        case .closest: return (weight: closestWeight, text: "\(Weight.friendlyStr(closestWeight)) lbs", plates: closestPlates)
        case .upper: return (weight: upperWeight, text: "\(Weight.friendlyStr(upperWeight)) lbs", plates: upperPlates)
        }
    }
    
    var description: String {
        return String(format: "%.3f", weight)
    }
    
    // This is for unit testing
    internal func weights(_ exercise: Exercise) -> String {
        var result = ""
        
        let g = createGenerator(exercise)
        result += String(format: "%.2f", g.first().0)
        while true {
            if let candidate = g.next() {
                result += ", " + String(format: "%.2f", candidate.0)
            }
            else
            {
                break
            }
        }
        
        return result
    }
    
    // This is for unit testing
    internal func labels(_ exercise: Exercise) -> String {
        var result = ""
        
        let g = createGenerator(exercise)
        result += g.first().1
        while true {
            if let candidate = g.next() {
                result += ", " + candidate.1
            }
            else
            {
                break
            }
        }

        return result
    }
    
    private func findRange(_ exercise: Exercise) -> (Double, String, Double, String, Double, String) {
        let g = createGenerator(exercise)
        
        let first = g.first()
        if first.0 > weight {
            // First option is larger than the weight so that's our only option.
            return (first.0, first.1, first.0, first.1, first.0, first.1)
        }
        var lowerWeight = first.0
        var lowerPlates = first.1
        var closestWeight = first.0
        var closestPlates = first.1

        while true {
            if let candidate = g.next() {
                if abs(candidate.0 - weight) < abs(closestWeight - weight) {
                    closestWeight = candidate.0
                    closestPlates = candidate.1
                }

                if candidate.0 > weight {
                    return (lowerWeight, lowerPlates, closestWeight, closestPlates, candidate.0, candidate.1)
                } else if candidate.0 < weight && candidate.0 < lowerWeight {   // prefer the first candidate (generators return the simplest combinations first)
                    lowerWeight = candidate.0
                    lowerPlates = candidate.1
                }
            }
            else
            {
                break
            }
        }
        
        // we've run out of weights but failed to find an upper weight.
        return (lowerWeight, lowerPlates, closestWeight, closestPlates, lowerWeight, lowerPlates)
    }
    
    private func createGenerator(_ exercise: Exercise) -> WeightGenerator {
        switch exercise.apparatus! {
        case .barbell(bar: let barWeight, collar: let collarWeight, plates: let plates, bumpers: let bumpers, magnets: let magnets):
            assert(barWeight == 0)  // TODO: support these
            assert(collarWeight == 0)
            assert(bumpers.isEmpty)
            assert(magnets.isEmpty)
            return PlatesGenerator(plates, pairedPlates: true)
        default:
            assert(false)   // TODO: get rid of this once we handle all the cases
        }
    }
    
    private static func friendlyStr(_ weight: Double) -> String
    {
        var result: String
        
        // Note that weights are always stored as lbs internally.
//        let app = UIApplication.shared.delegate as! AppDelegate
//        switch app.units()
//        {
//        case .imperial:
//            // Kind of annoying to use three decimal places but people
//            // sometimes use 0.625 fractional plates (5/8 lb).
            result = String(format: "%.3f", weight)
//
//        case .metric:
//            result = String(format: "%.2f", arguments: [weight*Double.lbToKg])
//        }
        
        while result.hasSuffix("0")
        {
            let start = result.index(result.endIndex, offsetBy: -1)
            let end = result.endIndex
            result.removeSubrange(start..<end)
        }
        if result.hasSuffix(".")
        {
            let start = result.index(result.endIndex, offsetBy: -1)
            let end = result.endIndex
            result.removeSubrange(start..<end)
        }
        
        return result
    }
    
    private class PlatesGenerator: WeightGenerator
    {
        init(_ plates: [(Int, Double)], pairedPlates: Bool) {
            assert(!plates.isEmpty)
            
            var p: [Double] = []
            
            // For an apparatus that takes two plates (like a barbell) we want to return info about one end
            // of the bar so we need to divide count by two so that we don't tell the user to add more plates
            // than he wants to use.
            let scaling = pairedPlates ? 2 : 1
            for (count, weight) in plates {
                for _ in 0..<count/scaling {
                    p.append(weight)
                }
            }
            
            // This isn't very elegant...
            var e: [(Double, String)] = []
            PlatesGenerator.add1(p, &e)
            PlatesGenerator.add2(p, &e)
            self.entries = e
        }
        
        func first() -> (Double, String) {
            return entries[0]
        }
        
        func next() -> (Double, String)? {
            index += 1
            return index < entries.count ? entries[index] : nil
        }
        
        private static func add1(_ plates: [Double], _ entries: inout [(Double, String)]) {
            // This can return the same plate more than once but that's OK.
            for w in plates {
                entries.append((w, PlatesGenerator.platesStr([w])))
            }
        }
        
        private static func add2(_ plates: [Double], _ entries: inout [(Double, String)]) {
            for i1 in 0..<plates.count-1 {
                for i2 in i1+1..<plates.count {
                    entries.append((plates[i1] + plates[i2], PlatesGenerator.platesStr([plates[i1], plates[i2]])))
                }
            }
        }
        
        // TODO: add more combinations
        
        private static func platesStr(_ plates: [Double]) -> String {
            let s = plates.map {(w) -> String in Weight.friendlyStr(w)}

            // "45 lb plate"
            if plates.count == 1 {
                return "\(s[0]) lb plate"
                
            // "2 10s"
            } else if s.all({(t) -> Bool in t == s[0]}) {
                return "\(plates.count) \(s[0])s"

            // "10 + 5 + 2.5"
            } else {
                return s.reversed().joined(separator: " + ")
            }
        }
        
        let entries: [(Double, String)]
        var index = 0
    }

    private let weight: Double
}
