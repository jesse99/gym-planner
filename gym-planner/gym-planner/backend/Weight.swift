/// Types used to manage weights.
import Foundation
import os.log

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
    
    struct Info: Storable {
        // 145.0
        let weight: Double
        
        // "145 lbs"
        let text: String
        
        // "45 + 5"
        let plates: String

        init(weight: Double, text: String, plates: String) {
            self.weight = weight
            self.text = text
            self.plates = plates
        }
        
        init(from store: Store) {
            self.weight = store.getDbl("weight")
            self.text = store.getStr("text")
            self.plates = store.getStr("plates")
        }
        
        func save(_ store: Store) {
            store.addDbl("weight", weight)
            store.addStr("text", text)
            store.addStr("plates", plates)
        }
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
    
    /// Returns the weight immediately above weight.
    func nextWeight() -> Double {
        let (_, _, _, _, upperWeight, _) = findRange()
        return upperWeight
    }
    
    var description: String {
        return String(format: "%.3f", weight)
    }
    
    static func friendlyStr(_ weight: Double) -> String
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
    
    static func friendlyUnitsStr(_ weight: Double, plural: Bool = true) -> String
    {
        if plural {
            return Weight.friendlyStr(weight) + " lbs"  // TODO: also kg
        } else {
            return Weight.friendlyStr(weight) + " lb"
        }
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
        //os_log("---- weight = %.3f ---------------------------------------------------", type: .info, weight)
        let g = createGenerator()
        
        let first = g.first()
//        os_log("candidate = %.3f (%@)", type: .info, first.0, first.1)
        var lowerWeight = first.0
        var lowerPlates = first.1
        var closestWeight = first.0
        var closestPlates = first.1
        var upperWeight = first.0
        var upperPlates = first.1

        while true {
            if let candidate = g.next() {
//                let log = abs(candidate.0 - weight) < 10.0
//                if log {
//                    os_log("candidate = %.3f (%@)", type: .info, candidate.0, candidate.1)
//                }
                if candidate.0 < weight && candidate.0 > lowerWeight {   // always prefer the first candidate (generators return the simplest combinations first)
//                    if !log {
//                        os_log("candidate = %.3f (%@)", type: .info, candidate.0, candidate.1)
//                    }
//                    os_log("   new lower", type: .info)
                    lowerWeight = candidate.0
                    lowerPlates = candidate.1
                }

                if abs(candidate.0 - weight) < abs(closestWeight - weight) {
//                    if !log {
//                        os_log("candidate = %.3f (%@)", type: .info, candidate.0, candidate.1)
//                    }
//                    os_log("   new closer", type: .info)
                    closestWeight = candidate.0
                    closestPlates = candidate.1
                }

                if candidate.0 > weight && (candidate.0 < upperWeight || upperWeight < weight) {
//                if candidate.0 > weight && (upperWeight - weight < 0.01 || abs(candidate.0 - weight) < abs(upperWeight - weight)) {
//                    if !log {
//                        os_log("candidate = %.3f (%@)", type: .info, candidate.0, candidate.1)
//                    }
//                    os_log("   new upper", type: .info)
                    upperWeight = candidate.0
                    upperPlates = candidate.1
                }
                
                // TODO: see how fast this on a real phone, if it looks a little slow we could optimize this by bailing
                // when we have good values for lower and upper
            }
            else {
                break
            }
        }
        
        // lowerWeight starts out at the smallest weight so we'll always have a decent value.
        // But if upperWeight is too large for the available weights we need to fall back to whatever was closest.
        if upperWeight < weight {
            upperWeight = closestWeight
            upperPlates = closestPlates
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
    
    private class PlatesGenerator: WeightGenerator
    {
        init(_ barWeight: Double, _ collarWeight: Double, _ plates: [(Int, Double)], _ bumpers: [(Int, Double)], _ magnets: [Double], pairedPlates: Bool) {            
            var p: [(Double, String)] = []
            
            entries.reserveCapacity(1000)
            if barWeight > 0.0 {
                self.entries.append((barWeight, ""))
            }

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
            self.pairedPlates = pairedPlates
            
            if !p.isEmpty {
                add1()
            }
            if entries.isEmpty {
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
            let scaling = pairedPlates ? 2.0 : 1.0
            for w in plates {
                if !hasBumper || w.1 == "bumper" {  // If the user says to use bumpers then we'll always use them (so stuff like deadlifts isn't super annoying at lighter weights)
                    if w.1 != "magnet" {  // don't allow just a magnet
                        entries.append((fixedWeight + scaling*w.0, PlatesGenerator.platesStr([w])))
                    }
                }
            }
        }
        
        private func add2() {
            let scaling = pairedPlates ? 2.0 : 1.0
            if plates.count >= 2 {
                for i1 in 0..<plates.count-1 {
                    for i2 in i1+1..<plates.count {
                        if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" {
                            if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" {
                                let w = plates[i1].0 + plates[i2].0
                                entries.append((fixedWeight + scaling*w, PlatesGenerator.platesStr([plates[i1], plates[i2]])))
                            }
                        }
                    }
                }
            }
        }

        private func add3() {
            let scaling = pairedPlates ? 2.0 : 1.0
            if plates.count >= 3 {
                for i1 in 0..<plates.count-2 {
                    for i2 in i1+1..<plates.count-1 {
                        for i3 in i2+1..<plates.count {
                            if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" || plates[i3].1 == "bumper" {
                                if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" || plates[i3].1 != "magnet" {
                                    let w = plates[i1].0 + plates[i2].0 + plates[i3].0
                                    entries.append((fixedWeight + scaling*w, PlatesGenerator.platesStr([plates[i1], plates[i2], plates[i3]])))
                                }
                            }
                        }
                    }
                }
            }
        }

        private func add4() {
            if plates.count >= 4 {
                let scaling = pairedPlates ? 2.0 : 1.0
                for i1 in 0..<plates.count-3 {
                    for i2 in i1+1..<plates.count-2 {
                        for i3 in i2+1..<plates.count-1 {
                            for i4 in i3+1..<plates.count {
                                if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" || plates[i3].1 == "bumper" || plates[i4].1 == "bumper" {
                                    if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" || plates[i3].1 != "magnet" || plates[i4].1 != "magnet" {
                                        let w = plates[i1].0 + plates[i2].0 + plates[i3].0 + plates[i4].0
                                        entries.append((fixedWeight + scaling*w, PlatesGenerator.platesStr([plates[i1], plates[i2], plates[i3], plates[i4]])))
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
                let scaling = pairedPlates ? 2.0 : 1.0
                for i1 in 0..<plates.count-4 {
                    for i2 in i1+1..<plates.count-3 {
                        for i3 in i2+1..<plates.count-2 {
                            for i4 in i3+1..<plates.count-1 {
                                for i5 in i4+1..<plates.count {
                                    if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" || plates[i3].1 == "bumper" || plates[i4].1 == "bumper" || plates[i5].1 == "bumper" {
                                        if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" || plates[i3].1 != "magnet" || plates[i4].1 != "magnet" || plates[i5].1 != "magnet" {
                                            let w = plates[i1].0 + plates[i2].0 + plates[i3].0 + plates[i4].0 + plates[i5].0
                                            entries.append((fixedWeight + scaling*w, PlatesGenerator.platesStr([plates[i1], plates[i2], plates[i3], plates[i4], plates[i5]])))
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
                let scaling = pairedPlates ? 2.0 : 1.0
                for i1 in 0..<plates.count-5 {
                    for i2 in i1+1..<plates.count-4 {
                        for i3 in i2+1..<plates.count-3 {
                            for i4 in i3+1..<plates.count-2 {
                                for i5 in i4+1..<plates.count-1 {
                                    for i6 in i5+1..<plates.count {
                                        if !hasBumper || plates[i1].1 == "bumper" || plates[i2].1 == "bumper" || plates[i3].1 == "bumper" || plates[i4].1 == "bumper" || plates[i5].1 == "bumper" || plates[i6].1 == "bumper" {
                                            if plates[i1].1 != "magnet" || plates[i2].1 != "magnet" || plates[i3].1 != "magnet" || plates[i4].1 != "magnet" || plates[i5].1 != "magnet" || plates[i6].1 != "magnet" {
                                                let w = plates[i1].0 + plates[i2].0 + plates[i3].0 + plates[i4].0 + plates[i5].0 + plates[i6].0
                                                entries.append((fixedWeight + scaling*w, PlatesGenerator.platesStr([plates[i1], plates[i2], plates[i3], plates[i4], plates[i5], plates[i6]])))
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
            // "45 lb plate"
            if plates.count == 1 {
                return "\(Weight.friendlyUnitsStr(plates[0].0, plural: false)) \(plates[0].1)"

            } else {
                var s = plates.map {(w) -> String in Weight.friendlyStr(w.0)}
                
                // "2 10s"
                // "10 + 5 + 2.5"
                var text = ""
                while let plate = s.popLast() {
                    var count = 1
                    while let plate2 = s.last, plate2 == plate {
                        count += 1
                        _ = s.popLast()
                    }
                    
                    if !text.isEmpty {
                        text += " + "
                    }
                    if count == 1 {
                        text += plate
                    } else {
                        text += "\(count) \(plate)s"
                    }
                }
                
                return text
            }
        }
        
        private let plates: [(Double, String)]  // (10.0, "plate") or (45.0, "bummper") or (1.25, "magnet")
        private let fixedWeight: Double
        private let hasBumper: Bool
        private let pairedPlates: Bool
        
        private var entries: [(Double, String)] = []
        private var index = 0
        private var combos = 1
    }

    private let weight: Double
    private let apparatus: Apparatus
}

/// Returned by deloadByDate.
struct Deload {
    /// The weight to use, this will be the same as the original weight if percent is nil.
    let weight: Double
    
    /// Set if a deload happened.
    let percent: Int?
    
    /// Number of weeks ago that the exercise was last performed.
    let weeks: Int
}

/// deloads is a percent to apply to weight, e.g. if deloads is [1.0, 1.0, 0.9, 0.8] then
/// if oldDate was 0 weeks ago deload by 0%
/// if oldDate was 1 week ago deload by 0%
/// if oldDate was 2 weeks ago deload by 10%
/// if oldDate was 3 or more weeks ago deload by 20%
func deloadByDate(_ weight: Double, _ oldDate: Date, _ deloads: [Double]) -> Deload {
    let weeks = Int(Date().weeksSinceDate(oldDate))
    let index = max(min(weeks, deloads.count - 1), 0)
    let percent = Int(100.0*(1.0 - deloads[index]))
    return Deload(weight: weight*deloads[index], percent: percent > 0 ? percent : nil, weeks: weeks)
}

