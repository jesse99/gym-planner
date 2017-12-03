/// Advance weight after each successful workout.
import Foundation
import os.log

public class LinearPlan : Plan {
    struct Set: Storable {
        let title: String      // "Workset 3 of 4"
        let subtitle: String
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = Weight(percent*weight, apparatus).closest(below: weight)
            self.numReps = numReps
            self.warmup = true

            let info = Weight(weight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, weight: Double) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.subtitle = ""
            self.weight = Weight(weight, apparatus).closest()
            self.numReps = numReps
            self.warmup = false
        }

        init(from store: Store) {
            self.title = store.getStr("title")
            self.subtitle = store.getStr("subtitle", ifMissing: "")
            self.numReps = store.getInt("numReps")
            self.weight = store.getObj("weight")
            self.warmup = store.getBool("warmup")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addStr("subtitle", subtitle)
            store.addInt("numReps", numReps)
            store.addObj("weight", weight)
            store.addBool("warmup", warmup)
        }
    }
    
    struct Result: VariableWeightResult, Storable {
        let title: String   // "135 lbs 3x5"
        let date: Date
        var missed: Bool
        var weight: Double
        
        var primary: Bool {get {return true}}
        
        init(title: String, missed: Bool, weight: Double) {
            self.title = title
            self.date = Date()
            self.missed = missed
            self.weight = weight
        }

        init(from store: Store) {
            self.title = store.getStr("title")
            self.date = store.getDate("date")
            self.missed = store.getBool("missed")
            self.weight = store.getDbl("weight")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addDate("date", date)
            store.addBool("missed", missed)
            store.addDbl("weight", weight)
        }
    }
    
    init(_ name: String, firstWarmup: Double, warmupReps: [Int], workSets: Int, workReps: Int) {
        os_log("init LinearPlan for %@", type: .info, name)
        self.name = name
        self.typeName = "LinearPlan"
        self.firstWarmup = firstWarmup
        self.warmupReps = warmupReps
        self.workSets = workSets
        self.workReps = workReps
        self.deloads = [1.0, 1.0, 0.95, 0.9, 0.85]
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? LinearPlan {
            return typeName == savedPlan.typeName &&
                name == savedPlan.name &&
                firstWarmup == savedPlan.firstWarmup &&
                warmupReps == savedPlan.warmupReps &&
                workSets == savedPlan.workSets &&
                workReps == savedPlan.workReps
        } else {
            return false
        }
    }

    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.typeName = "LinearPlan"
        self.firstWarmup = store.getDbl("firstWarmup")
        self.warmupReps = store.getIntArray("warmupReps")
        self.workSets = store.getInt("workSets")
        self.workReps = store.getInt("workReps")
        self.deloads = store.getDblArray("deloads")

        self.exerciseName = store.getStr("exerciseName")
        self.sets = store.getObjArray("sets")
        self.history = store.getObjArray("history")
        self.setIndex = store.getInt("setIndex")
    }

    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addDbl("firstWarmup", firstWarmup)
        store.addIntArray("warmupReps", warmupReps)
        store.addInt("workSets", workSets)
        store.addInt("workReps", workReps)
        store.addDblArray("deloads", deloads)
        
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("sets", sets)
        store.addObjArray("history", history)
        store.addInt("setIndex", setIndex)
    }
    
    // Plan methods
    public let name: String
    public let typeName: String
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: LinearPlan = store.getObj("self")
        return result
    }
    
    public func start(_ exerciseName: String) -> StartResult {
        os_log("starting LinearPlan for %@ and %@", type: .info, name, exerciseName)
        self.sets = []
        self.setIndex = 0
        self.exerciseName = exerciseName

        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if setting.weight == 0.0 {
                return .newPlan(NRepMaxPlan("Rep Max", workReps: workReps))
            }
            
            buildSets(setting)
            frontend.saveExercise(exerciseName)

            return .ok

        case .left(let err):
            return .error(err)
        }
    }
    
    public func refresh() {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if setting.weight > 0.0 {
                buildSets(setting)
            }
        case .left(_):
            break
        }
    }
    
    public func isStarted() -> Bool {
        return !sets.isEmpty && !finished()
    }
    
    public func underway() -> Bool {
        return isStarted() && setIndex > 0
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        if let set = sets.last {
            return "\(workSets)x\(workReps) @ \(set.weight.text)"
        } else {
            return ""
        }
    }
    
    public func prevLabel() -> String {
        switch findVariableWeightSetting(exerciseName) {
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
        frontend.assert(!finished(), "LinearPlan is finished in current")
        
        let info = sets[setIndex].weight
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: "\(repsStr(sets[setIndex].numReps)) @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: !finished() && !sets[setIndex].warmup, secs: secs)

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
    
    public func findLastWeight() -> Double? {
        return history.last?.weight
    }
    
    // Internal items
    private func doNext() {
        setIndex += 1
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish(_ missed: Bool) {
        setIndex += 1
        frontend.assert(finished(), "LinearPlan is not finished in doFinish")
        
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed = Date()
        }
        
        addResult(missed)
        handleAdvance(missed)
        frontend.saveExercise(exerciseName)
    }
    
    private func handleAdvance(_ missed: Bool) {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if !missed {
                let old = setting.weight
                let w = Weight(setting.weight, setting.apparatus)
                setting.changeWeight(w.nextWeight())
                setting.stalls = 0
                os_log("advanced from %.3f to %.3f", type: .info, old, setting.weight)
                
            } else {
                setting.sameWeight()
                setting.stalls += 1
                os_log("stalled = %dx", type: .info, setting.stalls)
                
                if setting.stalls >= 3 {
                    let info = Weight(0.9*setting.weight, setting.apparatus).closest(below: setting.weight)
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
        let result = Result(title: title, missed: missed, weight: sets.last!.weight.weight)
        history.append(result)
    }
    
    private func buildSets(_ setting: VariableWeightSetting) {
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
        
        sets = []
        let numWarmups = warmupsWithBar + warmupReps.count // TODO: some duplication here with other plans
        for i in 0..<warmupsWithBar {
            sets.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: warmupReps.first ?? 5, percent: 0.0, weight: weight))
        }
        
        let delta = warmupReps.count > 0 ? (0.9 - firstWarmup)/Double(warmupReps.count - 1) : 0.0
        for (i, reps) in warmupReps.enumerated() {
            let percent = firstWarmup + Double(i)*delta
            sets.append(Set(setting.apparatus, phase: warmupsWithBar + i + 1, phaseCount: numWarmups, numReps: reps, percent: percent, weight: weight))
        }
        
        for i in 0..<workSets {
            sets.append(Set(setting.apparatus, phase: i+1, phaseCount: workSets, numReps: workReps, weight: weight))
        }
    }
    
    private let firstWarmup: Double
    private let warmupReps: [Int]
    private let workSets: Int
    private let workReps: Int
    private let deloads: [Double]

    private var exerciseName: String = ""
    private var sets: [Set] = []
    private var history: [Result] = []
    private var setIndex: Int = 0
}


