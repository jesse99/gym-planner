/// Plan that uses a percent of the weight from another plan.
import Foundation
import os.log

public class PercentOfPlan : Plan {
    struct Set {
        let title: String      // "Workset 3 of 4"
        let subtitle: String   // "90% of 140 lbs"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = Weight(percent*weight, apparatus).find(.lower)
            self.numReps = numReps
            self.warmup = true

            let info = Weight(weight, apparatus).find(.closest)
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }

        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, weight: Double) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.subtitle = ""
            self.weight = Weight(weight, apparatus).find(.closest)
            self.numReps = numReps
            self.warmup = false
        }
    }
    
    struct Result: DerivedWeightResult {
        let title: String   // "135 lbs 3x5"
        let date: Date
        var weight: Double
    }
    
    init(_ name: String, _ otherName: String, firstWarmupPercent: Double, warmupReps: [Int], workSets: Int, workReps: Int, percent: Double) {
        self.name = name
        self.otherName = otherName
        self.firstWarmupPercent = firstWarmupPercent
        self.warmupReps = warmupReps
        self.workSets = workSets
        self.workReps = workReps
        self.percent = percent
    }
    
    // Plan methods
    public let name: String
    
    public func startup(_ program: Program, _ exercise: Exercise, _ persist: Persistence) -> StartupResult {
        os_log("entering PercentOfPlan for %@", type: .info, exercise.name)
        
        self.exercise = exercise
        self.persist = persist

        // initialize setting and history
        var key = ""
        do {
            // setting
            key = PercentOfPlan.settingKey(exercise, otherName)
            var data = try persist.load(key)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            self.setting = try decoder.decode(DerivedWeightSetting.self, from: data)
            
            // history
            key = PercentOfPlan.historyKey(exercise, otherName)
            data = try persist.load(key)
            self.history = try decoder.decode([Result].self, from: data)
            
        } catch {
            os_log("Couldn't load %@: %@", type: .info, key, error.localizedDescription) // note that this can happen the first time the exercise is performed
            
            self.history = []
            switch exercise.defaultSettings {
            case .derivedWeight(let setting): self.setting = setting
            default: assert(false); abort()
            }
        }

        // initialize sets
        switch getOtherWeight(program, persist) {
        case .left(let message):
            return .error(message)
            
        case .right(let otherWeight):
            let workingSetWeight = percent*otherWeight;
            os_log("workingSetWeight = %.3f", type: .info, workingSetWeight)
            
            var warmupsWithBar = 0
            switch setting.apparatus {
            case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
            default: break
            }
            
            var s: [Set] = []
            let numWarmups = warmupsWithBar + warmupReps.count
            for i in 0..<warmupsWithBar {
                s.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: warmupReps.first ?? 5, percent: 0.0, weight: workingSetWeight))
            }
            
            let delta = warmupReps.count > 0 ? (0.9 - firstWarmupPercent)/Double(warmupReps.count - 1) : 0.0
            for (i, reps) in warmupReps.enumerated() {
                let percent = firstWarmupPercent + Double(i)*delta
                s.append(Set(setting.apparatus, phase: warmupsWithBar + i + 1, phaseCount: numWarmups, numReps: reps, percent: percent, weight: workingSetWeight))
            }
            
            for i in 0...workSets {
                s.append(Set(setting.apparatus, phase: i+1, phaseCount: workSets, numReps: workReps, weight: workingSetWeight))
            }
            
            self.sets = s
            self.setIndex = 0
            return .ok
        }
    }
    
    public func label() -> String {
        return exercise.name
    }
    
    public func sublabel() -> String {
        if let weight = sets.last?.weight {
            let p = Int(100.0*self.percent)
            return "\(weight.text) (\(p)% of \(otherName))"

        } else {
            let p = Int(100.0*self.percent)
            return "\(p)% of \(otherName)"
        }
    }
    
    public func prevLabel() -> String {
        if let result = history.last {
            return "Previous was \(Weight.friendlyUnitsStr(result.weight))"
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        let weights = history.map {$0.weight}
        return makeHistoryLabel(Array(weights))
    }
    
    public func current(n: Int) -> Activity {
        assert(!finished())
        
        let info = sets[setIndex].weight
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: "\(sets[setIndex].numReps) reps @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }
    
    public func restSecs() -> Int {
        return sets[setIndex].warmup ? 0 : setting.restSecs
    }
    
    public func completions() -> [Completion] {
        if setIndex+1 < sets.count {
            return [Completion(title: "", isDefault: true, callback: {() -> Void in self.setIndex += 1})]
        } else {
            return [
                Completion(title: "Done", isDefault: false, callback: {() -> Void in self.doFinish()})]
        }
    }
    
    public func finished() -> Bool {
        return setIndex == sets.count
    }
    
    public func reset() {
        setIndex = 0
    }
    
    public func description() -> String {
        return "This does an exercise at a percentage of another exercises workset. It's typically used to perform a light or medium version of an exercise."
    }
    
    public func settings() -> Settings {
        return .derivedWeight(setting)
    }
    
    // Internal items
    static func settingKey(_ exercise: Exercise, _ otherName: String) -> String {
        return PercentOfPlan.planKey(exercise, otherName) + "-setting"
    }
    
    static func historyKey(_ exercise: Exercise, _ otherName: String) -> String {
        return PercentOfPlan.planKey(exercise, otherName) + "-history"
    }
    
    private static func planKey(_ exercise: Exercise, _ otherName: String) -> String {
        return "\(exercise.name)-percent-of-\(otherName)"
    }
    
    private func doFinish() {
        setIndex += 1
        assert(finished())
        
        saveResult()
    }
    
    private func saveResult() {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, date: Date(), weight: sets.last!.weight.weight)
        history.append(result)
        
        let key = PercentOfPlan.historyKey(exercise, otherName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(history)
            try persist.save(key, data)
        } catch {
            os_log("Error saving %@: %@", type: .error, key, error.localizedDescription)
        }
    }
    
    private func saveSetting() {
        let key = PercentOfPlan.settingKey(exercise, otherName)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        do {
            let data = try encoder.encode(setting)
            try persist.save(key, data)
        } catch {
            os_log("Error saving %@: %@", type: .error, key, error.localizedDescription)
        }
    }
    
    private func getOtherWeight(_ program: Program, _ persist: Persistence) -> Either<String, Double> {
        if let exercise = program.findExercise(otherName) {
            if let plan = program.findPlan(exercise.plan) {
                if case .ok = plan.startup(program, exercise, persist) {
                    switch plan.settings() {
                    case .variableWeight(let setting): return .right(setting.weight)
                    case .fixedWeight(let setting): return .right(setting.weight)
                    default: return .left("\(otherName) doesn't use a variable or fixed weight plan")
                    }
                } else {
                    return .left("Execute '\(otherName)' first")
                }
            } else {
                return .left("Couldn't find plan '\(exercise.plan)'")
            }
        } else {
            return .left("Couldn't find exercise '\(otherName)'")
        }
    }
    
    private let otherName: String
    private let firstWarmupPercent: Double
    private let warmupReps: [Int]
    private let workSets: Int;
    private let workReps: Int
    private let percent: Double

    private var persist: Persistence!
    private var exercise: Exercise!
    private var setting: DerivedWeightSetting!
    private var history: [Result]!
    private var sets: [Set]!

    private var setIndex: Int = 0
}


