/// Advance weight after each successful workout.
import Foundation
import os.log

public class LinearPlan : Plan {
    struct Set: Codable {
        let title: String      // "Workset 3 of 4"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = Weight(percent*weight, apparatus).find(.lower)
            self.numReps = numReps
            self.warmup = true
        }
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, weight: Double) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.weight = Weight(weight, apparatus).find(.closest)
            self.numReps = numReps
            self.warmup = false
        }
    }
    
    struct Result: VariableWeightResult, Codable {
        let title: String   // "135 lbs 3x5"
        let date: Date
        var missed: Bool
        var weight: Double
        
        var primary: Bool {get {return true}}
    }
    
    init(_ name: String, firstWarmup: Double, warmupReps: [Int], workSets: Int, workReps: Int) {
        os_log("init LinearPlan for %@", type: .info, name)
        self.name = name
        self.firstWarmup = firstWarmup
        self.warmupReps = warmupReps
        self.workSets = workSets
        self.workReps = workReps
    }
    
    // Plan methods
    public let name: String
    
    public func start(_ exerciseName: String) -> StartResult {
        os_log("starting LinearPlan for %@ and %@", type: .info, name, exerciseName)
        self.sets = []
        self.setIndex = 0
        self.exerciseName = exerciseName

        switch findSetting(exerciseName) {
        case .right(let setting):
            if setting.weight > 0 {
                return .newPlan(NRepMaxPlan("Rep Max", workReps: workReps))
            }
            
            let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
            let weight = deload.weight;
            
            if let percent = deload.percent {
                os_log("deloaded by %d%% (last was %d weeks ago)", type: .info, percent, deload.weeks)
            }
            os_log("weight = %.3f", type: .info, weight)
            
            var warmupsWithBar = 0
            switch setting.apparatus {
            case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
            default: break
            }
            
            let numWarmups = warmupsWithBar + warmupReps.count // TODO: some duplication here with other plans
            for i in 0..<warmupsWithBar {
                sets.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: warmupReps.first ?? 5, percent: 0.0, weight: weight))
            }
            
            let delta = warmupReps.count > 0 ? (0.9 - firstWarmup)/Double(warmupReps.count - 1) : 0.0
            for (i, reps) in warmupReps.enumerated() {
                let percent = firstWarmup + Double(i)*delta
                sets.append(Set(setting.apparatus, phase: warmupsWithBar + i + 1, phaseCount: numWarmups, numReps: reps, percent: percent, weight: weight))
            }
            
            for i in 0...workSets {
                sets.append(Set(setting.apparatus, phase: i+1, phaseCount: workSets, numReps: workReps, weight: weight))
            }
            frontend.saveExercise(exerciseName)

            return .ok

        case .left(let err):
            return .error(err)
        }
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        if let set = sets.last {
            return "\(set.numReps) reps @ \(set.weight.text)"
        } else {
            return ""
        }
    }
    
    public func prevLabel() -> String {
        switch findSetting(exerciseName) {
        case .right(let setting):
            let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads);
            if let percent = deload.percent {
                return "Deloaded by \(percent)% (last was \(deload.weeks) ago)"
            } else {
                return makePrevLabel(history)
            }

        case .left(let err):
            return err
        }
    }
    
    public func historyLabel() -> String {
        let weights = history.map {$0.weight}
        return makeHistoryLabel(Array(weights))
    }
    
    public func current() -> Activity {
        assert(!finished())
        
        let info = sets[setIndex].weight
        return Activity(
            title: sets[setIndex].title,
            subtitle: "",
            amount: "\(sets[setIndex].numReps) reps @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }
    
    public func restSecs() -> RestTime {
        switch findSetting(exerciseName) {
        case .right(let setting):
            return RestTime(autoStart: !finished() && !sets[setIndex].warmup, secs: setting.restSecs)

        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func completions() -> [Completion] {
        if setIndex+1 < sets.count {
            return [Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})]
        } else {
            return [
                Completion(title: "Finished OK",  isDefault: true,  callback: {() -> Void in self.doFinish(false)}),
                Completion(title: "Missed a rep", isDefault: false, callback: {() -> Void in self.doFinish(true)})]
        }
    }
    
    public func atStart() -> Bool {
        return setIndex == 0
    }
    
    public func finished() -> Bool {
        return setIndex == sets.count
    }
    
    public func reset() {
        setIndex = 0
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "In this plan weights are advanced each time the lifter successfully completes an exercise. If the lifter fails to do all reps three times in a row then the weight is reduced by 10%. This plan is used by beginner programs like StrongLifts."
    }
    
    // Internal items
    private func doNext() {
        setIndex += 1
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish(_ missed: Bool) {
        setIndex += 1
        assert(finished())
        
        addResult(missed)
        handleAdvance(missed)
        frontend.saveExercise(exerciseName)
    }
    
    private func handleAdvance(_ missed: Bool) {
        switch findSetting(exerciseName) {
        case .right(let setting):
            if !missed {
                let w = Weight(setting.weight, setting.apparatus)
                setting.changeWeight(w.nextWeight())
                setting.stalls = 0
                os_log("advanced to = %.3f", type: .info, setting.weight)
                
            } else {
                setting.sameWeight()
                setting.stalls += 1
                os_log("stalled = %dx", type: .info, setting.stalls)
                
                if setting.stalls >= 3 {
                    let info = Weight(0.9*setting.weight, setting.apparatus).find(.lower)
                    setting.changeWeight(info.weight)
                    setting.stalls = 0
                    os_log("deloaded to = %.3f", type: .info, setting.weight)
                }
            }

        case .left(let err):
            // Not sure if this can happen, maybe if the user edits the program after the plan starts.
            os_log("%@ advance failed: %@", type: .error, name, err)
            setIndex = sets.count
        }
    }
    
    private func addResult(_ missed: Bool) {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, date: Date(), missed: missed, weight: sets.last!.weight.weight)
        history.append(result)
    }
    
    private let firstWarmup: Double
    private let warmupReps: [Int]
    private let workSets: Int
    private let workReps: Int
    private let deloads: [Double] = [1.0, 1.0, 0.95, 0.9, 0.85]

    private var exerciseName: String = ""
    private var sets: [Set] = []
    private var history: [Result] = []
    private var setIndex: Int = 0
}


