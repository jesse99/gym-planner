/// Advances reps to a max and then advances weight.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class CycleRepsPlan : Plan {
    struct Set: Storable {
        let title: String      // "Workset 3 of 4"
        let subtitle: String   // "60% of 200 lbs"
        let amount: String     // "8 reps @ 200 lbs"
        let weight: Weight.Info
        let reps: Int
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, warmupWeight: Weight.Info, workingSetWeight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = warmupWeight
            self.reps = numReps
            self.warmup = true
            
            let info = Weight(workingSetWeight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"

            let prefix = repsStr(numReps)
            self.amount = "\(prefix) @ \(self.weight.text)"
        }
        
        init(_ apparatus: Apparatus, set: Int, numSets: Int, numReps: Int, maxReps: Int, workingSetWeight: Double) {
            self.title = "Workset \(set) of \(numSets)"
            self.weight = Weight(workingSetWeight, apparatus).closest()
            self.reps = numReps
            self.subtitle = ""
            self.warmup = false

            let prefix = numReps < maxReps ? "\(numReps)-\(maxReps) reps" : repsStr(reps)
            self.amount = "\(prefix) @ \(self.weight.text)"
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.subtitle = store.getStr("subtitle", ifMissing: "")
            self.amount = store.getStr("amount")
            self.weight = store.getObj("weight", ifMissing: Weight.Info(weight: 0.0, text: "0 lbs", plates: ""))
            self.reps = store.getInt("reps", ifMissing: 5)
            self.warmup = store.getBool("warmup", ifMissing: false)
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addStr("subtitle", subtitle)
            store.addStr("amount", amount)
            store.addObj("weight", weight)
            store.addInt("reps", reps)
            store.addBool("warmup", warmup)
        }
    }
    
    class Result: WeightedResult {
        init(_ numSets: Int, _ numReps: Int, _ weight: Weight.Info) {
            self.numSets = numSets
            self.numReps = numReps
            
            let title = "\(numSets)x\(numReps) @ \(weight.text)"
            super.init(title, weight.weight, primary: true, missed: false)
        }
        
        required init(from store: Store) {
            self.numSets = store.getInt("numSets")
            self.numReps = store.getInt("numReps")
            super.init(from: store)
        }
        
        public override func save(_ store: Store) {
            super.save(store)
            store.addInt("numSets", numSets)
            store.addInt("numReps", numReps)
        }
        
        internal override func updatedWeight(_ newWeight: Weight.Info) {
            title = "\(numSets)x\(numReps) @ \(newWeight.text)"
        }
        
        let numSets: Int
        let numReps: Int
    }
    
    init(_ name: String, _ warmups: Warmups, numSets: Int, minReps: Int, maxReps: Int) {
        os_log("init CycleRepsPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "CycleRepsPlan"
        self.numSets = numSets
        self.minReps = minReps
        self.maxReps = maxReps
        self.warmups = warmups
        self.deloads = defaultDeloads
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? CycleRepsPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                numSets == savedPlan.numSets &&
                minReps == savedPlan.minReps &&
                maxReps == savedPlan.maxReps &&
                warmups == savedPlan.warmups
        } else {
            return false
        }
    }
    
    private let defaultDeloads: [Double] = [1.0, 1.0, 0.95, 0.9, 0.85]
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "CycleRepsPlan"
        self.numSets = store.getInt("numSets")
        self.minReps = store.getInt("minReps")
        self.maxReps = store.getInt("maxReps")
        self.deloads = store.getDblArray("deloads", ifMissing: defaultDeloads)
        
        if !store.hasKey("warmups") {
            let firstWarmup = store.getDbl("firstWarmup", ifMissing: 0.0)
            let warmupReps = store.getIntArray("warmupReps", ifMissing: [])
            self.warmups = Warmups(withBar: 2, firstPercent: firstWarmup, lastPercent: 0.9, reps: warmupReps)
        } else {
            self.warmups = store.getObj("warmups")
        }

        self.workoutName = store.getStr("workoutName")
        self.exerciseName = store.getStr("exerciseName")
        self.sets = store.getObjArray("sets")
        self.history = store.getObjArray("history")
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
        store.addInt("numSets", numSets)
        store.addInt("minReps", minReps)
        store.addInt("maxReps", maxReps)
        store.addObj("warmups", warmups)
        store.addDblArray("deloads", deloads)

        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("sets", sets)
        store.addObjArray("history", history)
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
        let result: CycleRepsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting CycleRepsPlan for %@ and %@", type: .info, planName, exerciseName)
        self.sets = []
        self.setIndex = 0
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet
        
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if setting.weight == 0.0 {
                self.state = .blocked
                setting.reps = minReps
                return NRepMaxPlan("Rep Max", workReps: minReps)
            }
            
            self.state = .started
            buildSets(setting)
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
    
    private let defaultRequested = 5
    
    public func sublabel() -> String {
        if let set = sets.last {
            if set.reps < maxReps {
                return "\(numSets)x\(set.reps)-\(maxReps) @ \(set.weight.text)"
            } else {
                return "\(numSets)x\(set.reps) @ \(set.weight.text)"
            }
        } else {
            return ""
        }
    }
    
    public func prevLabel() -> String {
        if let deload = deloadedWeight(), let percent = deload.percent {
            return "Deloaded by \(percent)% (last was \(deload.weeks) weeks ago)"
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        let labels = history.map {"\($0.numReps) @ \(Weight.friendlyUnitsStr($0.getWeight()))"}
        return makeHistoryFromLabels(labels)
    }
    
    public func current() -> Activity {
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: sets[setIndex].amount,
            details: "",
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
                return RestTime(autoStart: setIndex > 0 && !sets[setIndex-1].warmup, secs: secs)
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
            let completions: [Completion] = [
                Completion(title: "Maintain",     isDefault: false, callback: {() -> Void in self.doFinish(advanceBy: 0)}),
                Completion(title: "Advance by 1", isDefault: false, callback: {() -> Void in self.doFinish(advanceBy: 1)}),
                Completion(title: "Advance by 2", isDefault: false, callback: {() -> Void in self.doFinish(advanceBy: 2)}),
                Completion(title: "Advance by 3", isDefault: false, callback: {() -> Void in self.doFinish(advanceBy: 3)}),
                Completion(title: "Advance by 4", isDefault: false, callback: {() -> Void in self.doFinish(advanceBy: 4)})]
            return .normal(completions)
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
        return "Reps advance from a min to a max. Then weight is advanced and reps drop back to the min. Often used for accessories like a Lat Pulldown."
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
    
    private func doFinish(advanceBy: Int) {
        modifiedOn = Date()
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        if advanceBy > 0 {
            handleAdvance(advanceBy)
        }
        addResult(sets.last!.reps)
        frontend.saveExercise(exerciseName)
    }
    
    private func handleAdvance(_ advanceBy: Int) {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let oldReps = sets.last!.reps
            let newReps = oldReps + advanceBy
            let oldWeight = setting.weight
            setting.reps = newReps
            while setting.reps! > maxReps {
                setting.reps = minReps + (setting.reps! - maxReps) - 1
                let w = Weight(setting.weight, setting.apparatus)
                setting.changeWeight(w.nextWeight())
            }
            
            if setting.weight != oldWeight {
                os_log("advanced from %.3f to %.3f lbs", type: .info, oldWeight, setting.weight)
            }
            if setting.reps! != oldReps {
                os_log("advanced from %d to %d reps", type: .info, oldReps, setting.reps!)
            }
            
        case .left(let err):
            // Not sure if this can happen, maybe if the user edits the program after the plan starts.
            os_log("%@ advance failed: %@", type: .error, planName, err)
        }
    }
    
    private func addResult(_ reps: Int) {
        let weight = sets.last!.weight
        let result = Result(numSets, reps, weight)
        history.append(result)
    }
    
    private func buildSets(_ setting: VariableWeightSetting) {
        let weight = setting.weight
        os_log("weight = %.3f", type: .info, weight)
        
        sets = []
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)

        let warmupSets = warmups.computeWarmups(setting.apparatus, workingSetWeight: deload.weight)
        for (reps, setIndex, percent, warmupWeight) in warmupSets {
            sets.append(Set(setting.apparatus, phase: setIndex, phaseCount: warmupSets.count, numReps: reps, percent: percent, warmupWeight: warmupWeight, workingSetWeight: weight))
        }

        for i in 0..<numSets {
            let requested = setting.reps ?? defaultRequested
            sets.append(Set(setting.apparatus, set: i+1, numSets: numSets, numReps: requested, maxReps: maxReps, workingSetWeight: deload.weight))
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
    
    private let numSets: Int
    private let minReps: Int
    private let maxReps: Int
    private let warmups: Warmups
    private let deloads: [Double]

    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex = 0
}

