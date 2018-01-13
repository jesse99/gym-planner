/// Advance weight after each successful workout.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class AMRAPPlan : Plan {
    struct Set: Storable {
        let title: String       // "Workset 3 of 4"
        let subtitle: String    // "10% of 200 lbs"
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
    
    class Result: WeightedResult {
        init(_ missed: Bool, _ weight: Weight.Info) {
            let title = weight.text
            super.init(title, weight.weight, primary: true, missed: missed)
        }
        
        required init(from store: Store) {
            super.init(from: store)
        }
        
        internal override func updatedWeight(_ newWeight: Weight.Info) {
            title = newWeight.text
        }
    }
    
    init(_ name: String, firstWarmup: Double, warmupReps: [Int], workSets: Int, workReps: Int) {
        os_log("init AMRAPPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "AMRAPPlan"
        self.firstWarmup = firstWarmup
        self.warmupReps = warmupReps
        self.workSets = workSets
        self.workReps = workReps
        self.deloads = [1.0, 1.0, 0.95, 0.9, 0.9, 0.85]
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? AMRAPPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                firstWarmup == savedPlan.firstWarmup &&
                warmupReps == savedPlan.warmupReps &&
                workSets == savedPlan.workSets &&
                workReps == savedPlan.workReps
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "AMRAPPlan"
        self.firstWarmup = store.getDbl("firstWarmup")
        self.warmupReps = store.getIntArray("warmupReps")
        self.workSets = store.getInt("workSets")
        self.workReps = store.getInt("workReps")
        self.deloads = store.getDblArray("deloads")
        
        self.workoutName = store.getStr("workoutName")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.sets = store.getObjArray("sets")
        self.setIndex = store.getInt("setIndex")
        self.state = store.getObj("state")
        self.modifiedOn = store.getDate("modifiedOn")
        
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
        store.addDbl("firstWarmup", firstWarmup)
        store.addIntArray("warmupReps", warmupReps)
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
        let result: AMRAPPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting AMRAPPlan for %@ and %@", type: .info, planName, exerciseName)
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
        var weights = history.map {$0.getWeight()}
        if let deload = deloadedWeight() {
            weights.append(deload.weight)
        }
        return makeHistoryLabel(Array(weights))
    }
    
    public func current() -> Activity {
        let info = sets[setIndex].weight
        let reps = repsStr(sets[setIndex].numReps, amrap: setIndex+1 == sets.count)
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: "\(reps) @ \(info.text)",
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
                Completion(title: "Advance x2",  isDefault: false,  callback: {() -> Void in self.doFinish(2)}),
                Completion(title: "Advance",  isDefault: true,  callback: {() -> Void in self.doFinish(1)}),
                Completion(title: "Don't Advance",  isDefault: false,  callback: {() -> Void in self.doFinish(0)}),
                Completion(title: "Deload", isDefault: false, callback: {() -> Void in self.doDeload()})])
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
        return "Last set is As Many Reps As Possible (AMRAP). After completing the exercise the user is given four options: 1) Advance x2 can be selected if the user was able to do more than twice the miniumum number of reps in the AMRAP set 2) Advance is what the user should normally select which will bump up the working set weight 3) Don't Advance won't change anything 4) Deload will drop the working set weight by 10% and should be selected if the user cannot do the mimimum number of reps. This plan is used by beginner programs like Phrak's GSLP."
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
    
    private func doFinish(_ advanceFactor: Int) {
        modifiedOn = Date()
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        addResult(false)
        if advanceFactor == 1 {
            handleAdvance()
        } else if advanceFactor == 2 {
            handleAdvance()
            handleAdvance()
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func doDeload() {
        modifiedOn = Date()
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        addResult(true)

        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let info = Weight(0.9*setting.weight, setting.apparatus).closest(below: setting.weight)
            setting.changeWeight(info.weight)
            os_log("deloaded to = %.3f", type: .info, setting.weight)
            
        case .left(let err):
            // Not sure if this can happen, maybe if the user edits the program after the plan starts.
            os_log("%@ advance failed: %@", type: .error, planName, err)
            state = .error(err)
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func handleAdvance() {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let old = setting.weight
            let w = Weight(setting.weight, setting.apparatus)
            setting.changeWeight(w.nextWeight())
            os_log("advanced from %.3f to %.3f", type: .info, old, setting.weight)
            
        case .left(let err):
            // Not sure if this can happen, maybe if the user edits the program after the plan starts.
            os_log("%@ advance failed: %@", type: .error, planName, err)
            state = .error(err)
        }
    }
    
    private func addResult(_ missed: Bool) {
        let weight = sets.last!.weight
        let result = Result(missed, weight)
        history.append(result)
    }
    
    private func buildSets(_ setting: VariableWeightSetting) {
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
        let weight = deload.weight
        
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
        let numWarmups = warmupsWithBar + warmupReps.count
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
    
    private func deloadedWeight() -> Deload? {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
            return deload
            
        case .left(_):
            return nil
        }
    }
    
    private let firstWarmup: Double
    private let warmupReps: [Int]
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

