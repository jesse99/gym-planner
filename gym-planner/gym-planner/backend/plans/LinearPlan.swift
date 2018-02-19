/// Advance weight after each successful workout.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class LinearPlan : Plan {
    struct Set: Storable {
        let title: String       // "Workset 3 of 4"
        let subtitle: String    // "10% of 200 lbs"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, warmupWeight: Weight.Info, workingSetWeight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = warmupWeight
            self.numReps = numReps
            self.warmup = true

            let info = Weight(workingSetWeight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, workingSetWeight: Double) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.subtitle = ""
            self.weight = Weight(workingSetWeight, apparatus).closest()
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
    
    class Result: WeightedResult {
        init(_ numSets: Int, _ numReps: Int, _ missed: Bool, _ weight: Weight.Info) {
            self.numSets = numSets
            self.numReps = numReps
            
            let title = "\(weight.text) \(numSets)x\(numReps)"
            super.init(title, weight.weight, primary: true, missed: missed)
        }

        required init(from store: Store) {
            self.numSets = store.getInt("numSets", ifMissing: 0)
            self.numReps = store.getInt("numReps", ifMissing: 0)
            super.init(from: store)
        }
        
        public override func save(_ store: Store) {
            super.save(store)
            store.addInt("numSets", numSets)
            store.addInt("numReps", numReps)
        }
        
        internal override func updatedWeight(_ newWeight: Weight.Info) {
            title = "\(newWeight.text) \(numSets)x\(numReps)"
        }
        
        let numSets: Int
        let numReps: Int
    }
    
    init(_ name: String, _ warmups: Warmups, workSets: Int, workReps: Int) {
        os_log("init LinearPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "LinearPlan"
        self.warmups = warmups
        self.workSets = workSets
        self.workReps = workReps
        self.deloads = [1.0, 1.0, 0.95, 0.9, 0.85]
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? LinearPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                warmups == savedPlan.warmups &&
                workSets == savedPlan.workSets &&
                workReps == savedPlan.workReps
        } else {
            return false
        }
    }

    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "LinearPlan"
        self.workSets = store.getInt("workSets")
        self.workReps = store.getInt("workReps")
        self.deloads = store.getDblArray("deloads")
        
        if !store.hasKey("warmups") {
            let firstWarmup = store.getDbl("firstWarmup")
            let warmupReps = store.getIntArray("warmupReps")
            self.warmups = Warmups(withBar: 2, firstPercent: firstWarmup, lastPercent: 0.9, reps: warmupReps)
        } else {
            self.warmups = store.getObj("warmups")
        }

        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.sets = store.getObjArray("sets")
        self.setIndex = store.getInt("setIndex")
        self.state = store.getObj("state", ifMissing: .waiting)
        self.modifiedOn = store.getDate("modifiedOn", ifMissing: Date.distantPast)

        switch state {
        case .waiting:
            break
        default:
            let calendar = Calendar.current
            if !calendar.isDate(modifiedOn, inSameDayAs: Date()) {
                sets = []
                setIndex = 0
                state = .waiting
            }
        }
    }

    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addObj("warmups", warmups)
        store.addInt("workSets", workSets)
        store.addInt("workReps", workReps)
        store.addDblArray("deloads", deloads)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addObjArray("sets", sets)
        store.addInt("setIndex", setIndex)
        store.addDate("modifiedOn", modifiedOn)
        store.addObj("state", state)
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    public var state = PlanState.waiting

    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: LinearPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting LinearPlan for %@ and %@", type: .info, planName, exerciseName)
        self.sets = []
        self.setIndex = 0
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet

        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if setting.weight == 0.0 {
                self.state = .blocked
                return NRepMaxPlan("Rep Max", workReps: workReps)
            }
            
            buildSets(setting)
            self.state = .started
            frontend.saveExercise(exerciseName)

        case .left(let err):
            self.state = .error(err)
        }
        return nil
    }
    
    public func getHistory() -> [BaseResult] {
        return history
    }
    
    public func deleteHistory(_ index: Int) {
        history.remove(at: index)
        frontend.saveExercise(exerciseName)
    }
    
    public func on(_ workout: Workout) -> Bool {
        return workoutName == workout.name
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
        if let deload = deloadedWeight(), let percent = deload.percent {
            return "Deloaded by \(percent)% (last was \(deload.weeks) weeks ago)"
        } else {
            return makePrevLabel(history)
        }
    }
    
    public func historyLabel() -> String {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            var weights = history.map {$0.getWeight()}
            if let deload = deloadedWeight() {
                let info = Weight(deload.weight, setting.apparatus).closest()
                weights.append(info.weight)
            }
            return makeHistoryLabel(Array(weights))
        case .left(_):
            break
        }
        return ""
    }
    
    public func current() -> Activity {
        let info = sets[setIndex].weight
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: "\(repsStr(sets[setIndex].numReps)) @ \(info.text)",
            details: info.plates,
            buttonName: "Next",
            showStartButton: true,
            color: nil)
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            switch state {
            case .started, .underway: return RestTime(autoStart: setIndex > 0 && !sets[setIndex-1].warmup, secs: secs)
            default: return RestTime(autoStart: false, secs: secs)
            }
            
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func completions() -> Completions {
        if setIndex+1 < sets.count {
            return .normal([Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})])
        } else {
            return .normal([
                Completion(title: "Finished OK",  isDefault: true,  callback: {() -> Void in self.doFinish(false)}),
                Completion(title: "Missed a rep", isDefault: false, callback: {() -> Void in self.doFinish(true)})])
        }
    }
    
    public func reset() {
        setIndex = 0
        modifiedOn = Date()
        state = .started
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Weights are advanced each time the lifter successfully completes an exercise. If the lifter fails to do all reps three times in a row then the weight is reduced by 10%. This plan is used by beginner programs like StrongLifts."
    }
    
    public func currentWeight() -> Double? {
        if let deload = deloadedWeight() {
            return deload.weight
        } else {
            return nil
        }
    }
    
    // Internal items
    private func doNext() {
        setIndex += 1
        modifiedOn = Date()
        state = .underway
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish(_ missed: Bool) {
        modifiedOn = Date()
        state = .finished        
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
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
            os_log("%@ advance failed: %@", type: .error, planName, err)
            state = .error(err)
        }
    }
    
    private func addResult(_ missed: Bool) {
        let weight = sets.last!.weight
        let numSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let result = Result(numSets, sets.last!.numReps, missed, weight)
        history.append(result)
    }
    
    private func buildSets(_ setting: VariableWeightSetting) {
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
        let weight = deload.weight
        
        if let percent = deload.percent {
            os_log("deloaded by %d%% (last was %d weeks ago)", type: .info, percent, deload.weeks)
        }
        os_log("weight = %.3f", type: .info, weight)
        
        sets = []
        let warmupSets = warmups.computeWarmups(setting.apparatus, workingSetWeight: weight)
        for (reps, setIndex, percent, warmupWeight) in warmupSets {
            sets.append(Set(setting.apparatus, phase: setIndex, phaseCount: warmupSets.count, numReps: reps, percent: percent, warmupWeight: warmupWeight, workingSetWeight: weight))
        }
        
        for i in 0..<workSets {
            sets.append(Set(setting.apparatus, phase: i+1, phaseCount: workSets, numReps: workReps, workingSetWeight: weight))
        }
    }
    
    private func deloadedWeight() -> Deload? {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
            return deload
            
        case .left(_):
            return nil
        }
    }
    
    private let warmups: Warmups
    private let workSets: Int
    private let workReps: Int
    private let deloads: [Double]

    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex = 0
}
