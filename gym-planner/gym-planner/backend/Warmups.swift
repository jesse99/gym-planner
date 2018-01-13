import Foundation
import os.log

public struct Warmups: Storable {
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
    
    fileprivate let withBar: Int
    fileprivate let firstPercent: Double
    fileprivate let lastPercent: Double
    fileprivate let reps: [Int]
}

extension Warmups: Equatable {}

public func ==(lhs: Warmups, rhs: Warmups) -> Bool {
    return lhs.withBar == rhs.withBar &&
        lhs.firstPercent == rhs.firstPercent &&
        lhs.lastPercent == rhs.lastPercent &&
        lhs.reps == rhs.reps
}
