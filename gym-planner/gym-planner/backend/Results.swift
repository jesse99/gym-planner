// Used to show a list or chart of what happened with a particular exercise.
import Foundation

/// Results are used internally to do things like populate the previous and history labels.
/// GUIs can also use results to show logbooks and charts and also to edit results (although
/// not everything is exposed, e.g. rep ranges and cardio details).
public class BaseResult: Storable {
    let title: String
    let date: Date
    
    init(_ title: String) {
        self.title = title
        self.date = Date()
    }
    
    public required init(from store: Store) {
        self.title = store.getStr("title")
        self.date = store.getDate("date")
    }
    
    public func save(_ store: Store) {
        store.addStr("title", title)
        store.addDate("date", date)
    }
}

public class WeightedResult: BaseResult {
    /// This is the set for the exercise instance that really matters, e.g. the one where weight progresses.
    let primary: Bool
    
    /// True if the user was not able to complete what he was asked to do.
    var missed: Bool

    /// Can be zero.
    var weight: Double
    
    init(_ title: String, _ weight: Double, primary: Bool, missed: Bool) {
        self.weight = weight
        self.primary = primary
        self.missed = missed
        super.init(title)
    }
    
    public required init(from store: Store) {
        self.weight = store.getDbl("weight")
        self.primary = store.getBool("primary", ifMissing: false)
        self.missed = store.getBool("missed", ifMissing: false)
        super.init(from: store)
    }
    
    public override func save(_ store: Store) {
        super.save(store)
        store.addDbl("weight", weight)
        store.addBool("primary", primary)
        store.addBool("missed", missed)
    }
    
    public func updateTitle() {
        
    }
}

/// Given something like [100.0, 100.0, 100.0, 110.0, 120]
/// returns "+10 lbs x2, same x2"
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
    
    return makeHistoryFromLabels(labels)
}

public func makeHistoryFromLabels(_ labels: [String]) -> String {
    var entries: [String] = []
    var i = labels.count - 1
    while entries.count < 4 && i >= 0 {
        var count = 0
        while i-count >= 0 && labels[i-count] == labels[i] {
            count += 1
        }
        frontend.assert(count >= 1, "count is \(count) in makeHistoryFromLabels with \(labels)")
        
        if count == 1 {
            entries.append(labels[i])
        } else {
            entries.append(labels[i] + " x\(count)")
        }
        i -= count
    }
    
    return entries.joined(separator: ", ")
}

func makePrevLabel(_ history: [WeightedResult]) -> String {
    if let result = history.last {
        let count = countMisses(history)
        if count == 0 {
            return "Previous was \(Weight.friendlyUnitsStr(result.weight))"
        } else if count == 1 {
            return "Previous missed \(Weight.friendlyUnitsStr(result.weight))"
        } else {
            return "Previous missed \(Weight.friendlyUnitsStr(result.weight)) \(count)x"
        }
    } else {
        return ""
    }
}

internal func countMisses(_ history: [WeightedResult]) -> Int {
    var count = 0
    
    for result in history.reversed() {
        if result.missed {
            count += 1;
        } else {
            return count;
        }
    }
    
    return count
}
