import Foundation

/// Returns array of reps, set number, percent of workingSetWeight, and warmupWeight.
internal func computeWarmups(_ apparatus: Apparatus, _ warmupsWithBar: Int, _ firstWarmup: Double, _ warmupReps: [Int], workingSetWeight: Double) -> [(Int, Int, Double, Weight.Info)] {
    var warmups: [(Int, Int, Double, Weight.Info)] = []
    
    for i in 0..<warmupsWithBar {
        let percent = 0.0
        let weight = Weight(percent*workingSetWeight, apparatus).closest(below: workingSetWeight)
        warmups.append((warmupReps.first ?? 5, i + 1, percent, weight))
    }
    
    let delta = warmupReps.count > 1 ? (0.9 - firstWarmup)/Double(warmupReps.count - 1) : 0.0
    for (i, reps) in warmupReps.enumerated() {
        let percent = firstWarmup + Double(i)*delta
        let weight = Weight(percent*workingSetWeight, apparatus).closest(below: workingSetWeight)
        warmups.append((reps, warmupsWithBar + i + 1, percent, weight))
    }
    
    return warmups
}

