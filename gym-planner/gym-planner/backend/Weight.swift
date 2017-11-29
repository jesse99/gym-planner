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
    
    /// Note that if the direction constraint can't be satisfied this will return something as close as possible,
    /// e.g. doing a find using a weight below the smallest dumbbell will return the smallest dumbbell.
    func find(_ to: Direction) -> Info {
        switch apparatus {
        case .barbell(bar: let barWeight, collar: let collarWeight, plates: let plates, bumpers: let bumpers, magnets: let magnets, warmupsWithBar: _):
            let limit = 20
            let smallest = 2*min(plates.first ?? 45.0, bumpers.first ?? 45.0, magnets.first ?? 45.0)
            let floor = max(barWeight, weight - Double(limit/2)*smallest)
            
            // This can get a bit squirrelly when magnets are used because they can be much smaller than the
            // smallest plate and when bumpers are used because we don't want to just use the bare bar and the
            // smallest bumper can be a lot larger than the smallest plate. So we'll just find a bunch of
            // candidates about the target weight and select lowest, closest, and upper from those.
            var candidates: [Info] = []
            for n in 0..<limit {
                let x = findPairedPlates(floor + Double(n)*smallest, barWeight, collarWeight, plates, bumpers, magnets)
                candidates.append(x)
            }
            
            var delta = Double.infinity
            var first = candidates.count
            var last = candidates.count
            for (i, x) in candidates.enumerated() {
                let d = abs(x.weight - weight)
                if d < delta {
                    delta = d
                    first = i
                }
                if d == delta {
                    last = i
                }
            }

            switch to {
            case .lower: return first > 0 ? candidates[first-1] : candidates[first]
            case .closest: return candidates[first]
            case .upper: return last+1 < candidates.count ? candidates[last+1] : candidates[last]
            }
            
        case .dumbbells(_, _):
            frontend.assert(false, "find doesn't support dumbbells"); abort()
        }
    }
    
    /// Returns the weight immediately above weight.
    func nextWeight() -> Double {
        return find(.upper).weight
    }
    
    var description: String {
        return String(format: "%.3f", weight)
    }
    
    static func friendlyStr(_ weight: Double) -> String {
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
        
        while result.hasSuffix("0") {
            let start = result.index(result.endIndex, offsetBy: -1)
            let end = result.endIndex
            result.removeSubrange(start..<end)
        }
        if result.hasSuffix(".") {
            let start = result.index(result.endIndex, offsetBy: -1)
            let end = result.endIndex
            result.removeSubrange(start..<end)
        }
        
        return result
    }
    
    static func friendlyUnitsStr(_ weight: Double, plural: Bool = true) -> String {
        if plural {
            return Weight.friendlyStr(weight) + " lbs"  // TODO: also kg
        } else {
            return Weight.friendlyStr(weight) + " lb"
        }
    }
    
    private func findPairedPlates(_ target: Double, _ barWeight: Double, _ collarWeight: Double, _ plates: [Double], _ bumpers: [Double], _ magnets: [Double]) -> Info {
        var used: [(Double, String)] = []
        var sum = barWeight + 2*collarWeight
        
        var candidates = bumpers.map {($0, "bumper")}
        for p in plates {
            if !candidates.contains(where: {(x, _) -> Bool in x == p}) {
                candidates.append((p, "plate"))
            }
        }
        for m in magnets {
            if !candidates.contains(where: {(x, _) -> Bool in x == m}) {
                candidates.append((m, "magnet"))
            }
        }
        candidates.sort {$0.0 < $1.0}
        
        // Biggest plate can be added as many times as neccesary.
        if let (last, kind) = candidates.last {
            while sum + 2*last <= target {
                sum += 2*last
                used.append((last, kind))
            }
        }
        
        // Remaining plates can be added up to 2x.
        var addedMagnet = false
        for (plate, kind) in candidates.reversed() {
            if kind != "magnet" || (!used.isEmpty && !addedMagnet) {  // magnets require a plate and are only added once
                if sum + 2*plate <= target {
                    sum += 2*plate
                    used.append((plate, kind))
                    if kind == "magnet" {
                        addedMagnet = true
                    }
                }

                if kind != "magnet" {
                    if sum + 2*plate <= target {
                        sum += 2*plate
                        used.append((plate, kind))
                    }
                }
            }
        }
        
        // If there are bumpers then make sure that the user isn't using just the bar or a baby plate (or low weight deadlifts suck).
        if let first = bumpers.first, sum < barWeight + 2*collarWeight + 2*first {
            sum = barWeight + 2*collarWeight + 2*first
            used = [(first, "bumper")]
        }
        
        // Only use collars if we used a plate.
        if used.isEmpty {
            sum -= 2*collarWeight
        }
        
        return Info(weight: sum, text: Weight.friendlyUnitsStr(sum), plates: Weight.platesStr(used))
    }
    
    private static func platesStr(_ plates: [(Double, String)]) -> String {
        if plates.count == 0 {
            return "no plates"
            
        // "45 lb plate"
        } else if plates.count == 1 {
            return "\(Weight.friendlyUnitsStr(plates[0].0, plural: false)) \(plates[0].1)"

        } else {
            var s = plates.reversed().map {(w) -> String in Weight.friendlyStr(w.0)}
            
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

