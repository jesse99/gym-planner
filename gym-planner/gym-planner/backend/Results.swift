// Used to show a list or chart of what happened with a particular exercise.
import Foundation

protocol VariableWeightResult {
    var date: Date {get}
    var title: String {get}
    
    // This is set for the exercise instance that really matters, e.g. the one where weight progresses.
    var primary: Bool {get}
    
    var weight: Double {get set}    // TODO: should this be inside an enum? (so we can have one result type)
    var missed: Bool {get set}      // TODO: should we use an enum here?
}

protocol DerivedWeightResult {
    var date: Date {get}
    var title: String {get}
    var weight: Double {get set}
}

// Given something like [100.0, 100.0, 100.0, 110.0, 120]
// returns "+10 lbs x2, same x2"
public func makeHistoryLabel(_ weights: [Double]) -> String {
    let deltas = weights.mapi {(i, weight) -> Double in i > 0 ? weight - weights[i-1] : 0.0}
    let labels = deltas.dropFirst().map {(weight) -> String in
        if weight > 0.0 {
            return "+" + Weight.friendlyUnitsStr(weight)
        } else if weight == 0.0 {
            return "same"
        } else {
            return Weight.friendlyUnitsStr(weight)
        }
    }
    
    var entries: [String] = []
    var i = labels.count - 1
    while entries.count < 4 && i >= 0 {
        var count = 0
        while i-count >= 0 && labels[i-count] == labels[i] {
            count += 1
        }
        assert(count >= 1)
        
        if count == 1 {
            entries.append(labels[i])
        } else {
            entries.append(labels[i] + " x\(count)")
        }
        i -= count
    }
    
    return entries.joined(separator: ", ")
}
