import Foundation
import os.log

public struct Warmups: Storable, Equatable {
    init(withBar: Int, firstPercent: Double, lastPercent: Double, reps: [Int]) {
        self.withBar = withBar
        self.firstPercent = firstPercent
        self.lastPercent = lastPercent
        self.reps = reps
    }
    
    public init(from store: Store) {
        self.withBar = store.getInt("withBar")
        self.firstPercent = store.getDbl("firstPercent")
        self.lastPercent = store.getDbl("lastPercent")
        self.reps = store.getIntArray("reps")
    }
    
    public func save(_ store: Store) {
        store.addInt("withBar", withBar)
        store.addDbl("firstPercent", firstPercent)
        store.addDbl("lastPercent", lastPercent)
        store.addIntArray("reps", reps)
    }
    
    public static func ==(lhs: Warmups, rhs: Warmups) -> Bool {
        return lhs.withBar == rhs.withBar &&
            lhs.firstPercent == rhs.firstPercent &&
            lhs.lastPercent == rhs.lastPercent &&
            lhs.reps == rhs.reps
    }

    public func errors(prefix: String = "") -> [String] {
        var problems: [String] = []
        
        if withBar < 0 {
            problems += ["\(prefix)warmup.withBar is negative"]
        }
        
        if firstPercent < 0.0 {
            problems += ["\(prefix)warmup.firstPercent is negative"]
        }
        if firstPercent > 1.0 {
            problems += ["\(prefix)warmup.firstPercent is greater than 100%"]
        }

        if lastPercent < 0.0 {
            problems += ["\(prefix)warmup.lastPercent is negative"]
        }
        if lastPercent > 1.0 {
            problems += ["\(prefix)warmup.lastPercent is greater than 100%"]
        }
        
        if firstPercent > lastPercent {
            problems += ["\(prefix)warmup.firstPercent is greater than lastPercent"]
        }
        
        for (i, rep) in reps.enumerated() {
            if rep < 1 {
                problems += ["\(prefix)rep\(i+1) is less than 1"]
            }
        }

        return problems
    }
    
    /// Returns array of reps, set number, percent of workingSetWeight, and warmupWeight.
    internal func computeWarmups(_ apparatus: Apparatus, workingSetWeight: Double) -> [(Int, Int, Double, Weight.Info)] {
        var warmups: [(Int, Int, Double, Weight.Info)] = []
        
        for i in 0..<withBar {
            let percent = 0.0
            let weight = Weight(percent*workingSetWeight, apparatus).closest(below: workingSetWeight)
            warmups.append((reps.first ?? 5, i + 1, percent, weight))
        }
        
        let delta = reps.count > 1 ? (lastPercent - firstPercent)/Double(reps.count - 1) : 0.0
        for (i, reps) in reps.enumerated() {
            let percent = firstPercent + Double(i)*delta
            let weight = Weight(percent*workingSetWeight, apparatus).closest(below: workingSetWeight)
            warmups.append((reps, withBar + i + 1, percent, weight))
        }
        
        return warmups
    }

    /// Like the above except that warmups can be above unitWeight.
    internal func computeWarmups(_ apparatus: Apparatus, unitWeight: Double) -> [(Int, Int, Double, Weight.Info)] {
        var warmups: [(Int, Int, Double, Weight.Info)] = []
        
        for i in 0..<withBar {
            let percent = 0.0
            let weight = Weight(percent*unitWeight, apparatus).closest()
            warmups.append((reps.first ?? 5, i + 1, percent, weight))
        }
        
        let delta = reps.count > 1 ? (lastPercent - firstPercent)/Double(reps.count - 1) : 0.0
        for (i, reps) in reps.enumerated() {
            let percent = firstPercent + Double(i)*delta
            let weight = Weight(percent*unitWeight, apparatus).closest()
            warmups.append((reps, withBar + i + 1, percent, weight))
        }
        
        return warmups
    }
    
    fileprivate let withBar: Int
    fileprivate let firstPercent: Double
    fileprivate let lastPercent: Double
    fileprivate let reps: [Int]
}

