/// Types used to manage weights.
import Foundation

protocol WeightGenerator
{
    func first() -> (Double, String)
    
    // These are ordered by complexity, e.g. the combinations with the fewest plates are returned first
    func next() -> (Double, String)?
}

// TODO:
// units
internal struct Weight: CustomStringConvertible {
    enum Direction {
        case lower
        case closest
        case upper
    }
    
    struct Info {
        // 145.0
        let weight: Double
        
        // "145 lbs"
        let text: String
        
        // "45 + 5"
        let plates: String
    }
    
    init(_ weight: Double, _ apparatus: Apparatus) {
        self.weight = weight
        self.apparatus = apparatus
    }
    
    /// Note that if the direction constraint
    /// can't be satisfied this will return something as close as possible, e.g. doing a find using
    /// a weight below the smallest dumbbell will return the smallest dumbbell.
    func find(_ to: Direction) -> Info {
        let (lowerWeight, lowerPlates, closestWeight, closestPlates, upperWeight, upperPlates) = findRange()
        switch to {
        case .lower: return Info(weight: lowerWeight, text: "\(Weight.friendlyStr(lowerWeight)) lbs", plates: lowerPlates)
        case .closest: return Info(weight: closestWeight, text: "\(Weight.friendlyStr(closestWeight)) lbs", plates: closestPlates)
        case .upper: return Info(weight: upperWeight, text: "\(Weight.friendlyStr(upperWeight)) lbs", plates: upperPlates)
        }
    }
    
    var description: String {
        return String(format: "%.3f", weight)
    }
    
    // This is for unit testing
    internal func _weights() -> String {
        var result = ""
        
        let g = createGenerator()
        result += Weight.friendlyStr(g.first().0)
        while true {
            if let candidate = g.next() {
                result += ", " + Weight.friendlyStr(candidate.0)
            }
            else
            {
                break
            }
        }
        
        return result
    }
    
    // This is for unit testing
    internal func _labels() -> String {
        var result = ""
        
        let g = createGenerator()
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
    
    private func findRange() -> (Double, String, Double, String, Double, String) {
        let g = createGenerator()
        
        let first = g.first()
        var lowerWeight = first.0
        var lowerPlates = first.1
        var closestWeight = first.0
        var closestPlates = first.1
        var upperWeight = first.0
        var upperPlates = first.1

        while true {
            if let candidate = g.next() {
                if candidate.0 < weight && candidate.0 < lowerWeight {   // always prefer the first candidate (generators return the simplest combinations first)
                    lowerWeight = candidate.0
                    lowerPlates = candidate.1
                }

                if abs(candidate.0 - weight) < abs(closestWeight - weight) {
                    closestWeight = candidate.0
                    closestPlates = candidate.1
                }

                if candidate.0 > weight && abs(candidate.0 - weight) < abs(upperWeight - weight) {
                    upperWeight = candidate.0
                    upperPlates = candidate.1
                }
                
                // TODO: see how fast this on a real phone, if it looks a little slow we could optimize this by bailing
                // when we have good values for lower and upper
            }
            else
            {
                break
            }
        }
        
        return (lowerWeight, lowerPlates, closestWeight, closestPlates, upperWeight, upperPlates)
    }
    
    private func createGenerator() -> WeightGenerator {
        switch apparatus {
        case .barbell(bar: let barWeight, collar: let collarWeight, plates: let plates, bumpers: let bumpers, magnets: let magnets, warmupsWithBar: _):
            return PlatesGenerator(barWeight, collarWeight, plates, bumpers, magnets, pairedPlates: true)
        case .dumbbells(_, _):
            assert(false)
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
        init(_ barWeight: Double, _ collarWeight: Double, _ plates: [(Int, Double)], _ bumpers: [(Int, Double)], _ magnets: [Double], pairedPlates: Bool) {            
            var p: [(Double, String)] = []
            
            // For an apparatus that takes two plates (like a barbell) we want to return info about one end
            // of the bar so we need to divide count by two so that we don't tell the user to add more plates
            // than he wants to use.
            let scaling = pairedPlates ? 2 : 1
            for (count, weight) in bumpers {
                for _ in 0..<count/scaling {
                    p.append((weight, "bumper"))
                }
            }

            for (count, weight) in plates {
                for _ in 0..<count/scaling {
                    p.append((weight, "plate"))
                }
            }

            for weight in magnets {
                p.append((weight, "magnet"))
            }
            p.sort {$0.0 < $1.0}

            self.plates = p
            self.fixedWeight = barWeight + Double(scaling)*collarWeight
            self.hasBumper = !bumpers.isEmpty
            
            if !p.isEmpty {
                add1()
            } else {
                self.entries.append((0.0, ""))
            }
        }
        
        func first() -> (Double, String) {
            return entries[0]
        }
        
        func next() -> (Double, String)? {
            index += 1
            if index >= entries.count {
                index = 0
                combos += 1
                
                entries = []
                switch combos {
                case 2: add2()
                case 3: add3()
                case 4: add4()
                case 5: add5()
                case 6: add6()
                default: break
                }
            }
            return index < entries.count ? entries[index] : nil
        }
        
        private func add1() {
            // This can return the same plate more than once but that's OK.
            for w in plates {
                if !hasBumper || w.1 == "bumper" {  // If the user says to use bumpers then we'll always use them (so stuff like deadlifts isn't super annoying at lighter weights)
                    if w.1 != "magnet" {  // don't allow just a magnet
                        entries.append((fixedWeight + w.0, PlatesGenerator.platesStr([w])))
                    }
                }
            }
        }
        
        private func add2() {
            if plates.count >= 2 {
                for i1 in 0..<plates.count-1 {
                    for i2 in i1+1..<plates.count {
                        if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" {
                            if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" {
                                let w = plates[i1].0 + plates[i2].0
                                entries.append((fixedWeight + w, PlatesGenerator.platesStr([plates[i1], plates[i2]])))
                            }
                        }
                    }
                }
            }
        }

        private func add3() {
            if plates.count >= 3 {
                for i1 in 0..<plates.count-2 {
                    for i2 in i1+1..<plates.count-1 {
                        for i3 in i2+1..<plates.count {
                            if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" || plates[i3].1 == "bumper" {
                                if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" || plates[i3].1 != "magnet" {
                                    let w = plates[i1].0 + plates[i2].0 + plates[i3].0
                                    entries.append((fixedWeight + w, PlatesGenerator.platesStr([plates[i1], plates[i2], plates[i3]])))
                                }
                            }
                        }
                    }
                }
            }
        }

        private func add4() {
            if plates.count >= 4 {
                for i1 in 0..<plates.count-3 {
                    for i2 in i1+1..<plates.count-2 {
                        for i3 in i2+1..<plates.count-1 {
                            for i4 in i3+1..<plates.count {
                                if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" || plates[i3].1 == "bumper" || plates[i4].1 == "bumper" {
                                    if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" || plates[i3].1 != "magnet" || plates[i4].1 != "magnet" {
                                        let w = plates[i1].0 + plates[i2].0 + plates[i3].0 + plates[i4].0
                                        entries.append((fixedWeight + w, PlatesGenerator.platesStr([plates[i1], plates[i2], plates[i3], plates[i4]])))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        private func add5() {
            if plates.count >= 5 {
                for i1 in 0..<plates.count-4 {
                    for i2 in i1+1..<plates.count-3 {
                        for i3 in i2+1..<plates.count-2 {
                            for i4 in i3+1..<plates.count-1 {
                                for i5 in i4+1..<plates.count {
                                    if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" || plates[i3].1 == "bumper" || plates[i4].1 == "bumper" || plates[i5].1 == "bumper" {
                                        if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" || plates[i3].1 != "magnet" || plates[i4].1 != "magnet" || plates[i5].1 != "magnet" {
                                            let w = plates[i1].0 + plates[i2].0 + plates[i3].0 + plates[i4].0 + plates[i5].0
                                            entries.append((fixedWeight + w, PlatesGenerator.platesStr([plates[i1], plates[i2], plates[i3], plates[i4], plates[i5]])))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        private func add6() {
            if plates.count >= 6 {
                for i1 in 0..<plates.count-5 {
                    for i2 in i1+1..<plates.count-4 {
                        for i3 in i2+1..<plates.count-3 {
                            for i4 in i3+1..<plates.count-2 {
                                for i5 in i4+1..<plates.count-1 {
                                    for i6 in i5+1..<plates.count {
                                        if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" || plates[i3].1 == "bumper" || plates[i4].1 == "bumper" || plates[i5].1 == "bumper" || plates[i6].1 == "bumper" {
                                            if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" || plates[i3].1 != "magnet" || plates[i4].1 != "magnet" || plates[i5].1 != "magnet" || plates[i6].1 != "magnet" {
                                                let w = plates[i1].0 + plates[i2].0 + plates[i3].0 + plates[i4].0 + plates[i5].0 + plates[i6].0
                                                entries.append((fixedWeight + w, PlatesGenerator.platesStr([plates[i1], plates[i2], plates[i3], plates[i4], plates[i5], plates[i6]])))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        private static func platesStr(_ plates: [(Double, String)]) -> String {
            let s = plates.map {(w) -> String in Weight.friendlyStr(w.0)}

            // "45 lb plate"
            if plates.count == 1 {
                return "\(s[0]) lb \(plates[0].1)"
                
            // "2 10s"
            } else if s.all({(t) -> Bool in t == s[0]}) {
                return "\(plates.count) \(s[0])s"

            // "10 + 5 + 2.5"
            } else {
                return s.reversed().joined(separator: " + ")
            }
        }
        
        private let plates: [(Double, String)]  // (10.0, "plate") or (45.0, "bummper") or (1.25, "magnet")
        private let fixedWeight: Double
        private let hasBumper: Bool
        
        private var entries: [(Double, String)] = []
        private var index = 0
        private var combos = 1
    }

    private let weight: Double
    private let apparatus: Apparatus
}
