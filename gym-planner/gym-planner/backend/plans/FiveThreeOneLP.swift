/// 531 variant with weekly progression (from nsuns).
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class FiveThreeOneLPPlan : Plan {
    struct Set: Storable {
        let title: String       // "Set 3 of 4"
        let subtitle: String    // "10% of 200 lbs"
        let numReps: Int
        let weight: Weight.Info
        let amrap: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, workingSetWeight: Double, percent: Double) {
            self.title = "Set \(phase) of \(phaseCount)"
            self.weight = Weight(percent*workingSetWeight, apparatus).closest()
            self.numReps = numReps
            self.amrap = false
            
            let info = Weight(workingSetWeight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, amrap: Int, workingSetWeight: Double, percent: Double) {
            self.title = "Set \(phase) of \(phaseCount)"
            self.weight = Weight(percent*workingSetWeight, apparatus).closest()
            self.numReps = amrap
            self.amrap = true
            
            let info = Weight(workingSetWeight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.subtitle = store.getStr("subtitle", ifMissing: "")
            self.numReps = store.getInt("numReps")
            self.weight = store.getObj("weight")
            self.amrap = store.getBool("amrap")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addStr("subtitle", subtitle)
            store.addInt("numReps", numReps)
            store.addObj("weight", weight)
            store.addBool("amrap", amrap)
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
    
    public struct WorkSet: Storable {
        let reps: Int
        let percent: Double
        let amrap: Bool
        
        init(reps: Int, at: Double) {
            self.reps = reps
            self.percent = at
            self.amrap = false
        }
        
        init(amrap: Int, at: Double) {
            self.reps = amrap
            self.percent = at
            self.amrap = true
        }

        public init(from store: Store) {
            self.reps = store.getInt("reps")
            self.percent = store.getDbl("percent")
            self.amrap = store.getBool("amrap")
        }
        
        public func save(_ store: Store) {
            store.addInt("reps", reps)
            store.addDbl("percent", percent)
            store.addBool("amrap", amrap)
        }
    }
    
    init(_ name: String, _ sets: [WorkSet], workSetPercent: Double) {
        os_log("init FiveThreeOneLPPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "FiveThreeOneLPPlan"
        self.workSets = sets
        self.workSetPercent = workSetPercent
        self.deloads = [1.0, 1.0, 0.95, 0.9, 0.9, 0.85]
    }
    
    public func errors() -> [String] {
        var problems: [String] = []
        
        if workSets.count < 1 {
            problems += ["plan \(planName) workSets is less than 1"]
        }
        for (i, set) in workSets.enumerated() {
            if set.reps < 1 {
                problems += ["plan \(planName) set \(i+1) reps is less than 1"]
            }
            if set.percent < 0.0 {
                problems += ["plan \(planName) set \(i+1) percent is less than 0"]
            }
        }
        if workSetPercent < 0.0 {
            problems += ["plan \(planName) workSetPercent is less than 0"]
        }

        return problems
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? FiveThreeOneLPPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                workSetPercent == savedPlan.workSetPercent &&
                workSets == savedPlan.workSets
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.state = store.getObj("state")
        self.typeName = "FiveThreeOneLPPlan"
        self.workSets = store.getObjArray("workSets")
        self.workSetPercent = store.getDbl("workSetPercent")
        self.deloads = store.getDblArray("deloads")
        
        self.workoutName = store.getStr("workoutName")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.sets = store.getObjArray("sets")
        self.setIndex = store.getInt("setIndex")
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
        store.addObj("state", state)
        store.addObjArray("workSets", workSets)
        store.addDbl("workSetPercent", workSetPercent)
        store.addDblArray("deloads", deloads)
        
        store.addDate("modifiedOn", modifiedOn)
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addObjArray("sets", sets)
        store.addInt("setIndex", setIndex)
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    public var state = PlanState.waiting
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: FiveThreeOneLPPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        //os_log("starting FiveThreeOneLPPlan for %@ and %@", type: .info, planName, exerciseName)
        self.sets = []
        self.setIndex = 0
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet
        
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if setting.weight == 0.0 {
                self.state = .blocked
                return NRepMaxPlan("Rep Max", workReps: 5)
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
        if let m = sets.max(by: {(lhs, rhs) -> Bool in lhs.weight.weight < rhs.weight.weight}) {
            return m.weight.text
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
        let reps = repsStr(sets[setIndex].numReps, amrap: sets[setIndex].amrap)
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
            if case .finished = state {
                return RestTime(autoStart: false, secs: secs)
            } else {
                if let i = workSets.index(where: {$0.percent >= workSetPercent}) {
                    return RestTime(autoStart: setIndex > i, secs: secs)
                } else {
                    return RestTime(autoStart: false, secs: secs)
                }
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
                Completion(title: "Advance x3",   isDefault: false, callback: {() -> Void in self.doFinish(3)}),
                Completion(title: "Advance x2",   isDefault: false, callback: {() -> Void in self.doFinish(2)}),
                Completion(title: "Advance",      isDefault: true,  callback: {() -> Void in self.doFinish(1)}),
                Completion(title: "Don't Advance",isDefault: false, callback: {() -> Void in self.doFinish(0)})])
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
        return "This is typically used by 531 style programs with weekly linear progression. Rep schemes are usually something like 5@75%, 3@85%, 1+@95%, 3@90%, 3@85%, 3@80%, 5@75%, 5@70%, 5+@65% and weights go up if you're able to do more than one of the 1+ set."
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
        } else if advanceFactor == 3 {
            handleAdvance()
            handleAdvance()
            handleAdvance()
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
        
        sets = []
        for (i, set) in workSets.enumerated() {
            if set.amrap {
                sets.append(Set(setting.apparatus, phase: i+1, phaseCount: workSets.count, amrap: set.reps, workingSetWeight: weight, percent: set.percent))
            } else {
                sets.append(Set(setting.apparatus, phase: i+1, phaseCount: workSets.count, numReps: set.reps, workingSetWeight: weight, percent: set.percent))
            }
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
    
    private let workSets: [WorkSet]
    private let workSetPercent: Double
    private let deloads: [Double]
    
    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex = 0
}

extension FiveThreeOneLPPlan.WorkSet: Equatable {}

public func ==(lhs: FiveThreeOneLPPlan.WorkSet, rhs: FiveThreeOneLPPlan.WorkSet) -> Bool {
    return lhs.reps == rhs.reps && lhs.percent == rhs.percent && lhs.amrap == rhs.amrap
}
