/// Base class for plans that follow a weekly cycle.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class BaseCyclicPlan : Plan {
    struct Execute: Storable, Equatable {
        let workSets: Int
        let workReps: Int
        let percent: Double
        
        init(workSets: Int, workReps: Int, percent: Double) {
            self.workSets = workSets
            self.workReps = workReps
            self.percent = percent
        }
        
        init(from store: Store) {
            self.workSets = store.getInt("workSets")
            self.workReps = store.getInt("workReps")
            self.percent = store.getDbl("percent")
        }
        
        func save(_ store: Store) {
            store.addInt("workSets", workSets)
            store.addInt("workReps", workReps)
            store.addDbl("percent", percent)
        }
        
        static func ==(lhs: Execute, rhs: Execute)->Bool {
            return lhs.workSets == rhs.workSets && lhs.workReps == rhs.workReps && lhs.percent == rhs.percent
        }
    }
    
    struct Set: Storable {
        let title: String      // "Workset 3 of 4"
        let subtitle: String   // "90% of 140 lbs"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, warmupWeight: Weight.Info, workingSetWeight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = warmupWeight
            self.numReps = numReps
            self.warmup = true
            
            let info1 = Weight(workingSetWeight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info1.text)"
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
            self.subtitle = store.getStr("subtitle")
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
        let cycleIndex: Int
        
        init(_ numSets: Int, _ numReps: Int, _ cycleIndex: Int, _ missed: Bool, _ info: Weight.Info) {
            self.numSets = numSets
            self.numReps = numReps
            self.cycleIndex = cycleIndex
            let title = "\(info.text) \(numSets)x\(numReps)"
            super.init(title, info.weight, primary: cycleIndex == 0, missed: missed)
        }
        
        required init(from store: Store) {
            self.cycleIndex = store.getInt("cycleIndex")
            self.numSets = store.getInt("numSets", ifMissing: 0)
            self.numReps = store.getInt("numReps", ifMissing: 0)
            super.init(from: store)
        }
        
        override func save(_ store: Store) {
            super.save(store)
            store.addInt("cycleIndex", cycleIndex)
            store.addInt("numSets", numSets)
            store.addInt("numReps", numReps)
        }
        
        internal override func updatedWeight(_ newWeight: Weight.Info) {
            title = "\(newWeight.text) \(numSets)x\(numReps)"
        }
        
        let numSets: Int
        let numReps: Int
    }
    
    init(_ name: String, _ type: String, _ warmups: Warmups, _ cycles: [Execute], deloads: [Double]) {
        os_log("init %@ for %@", type: .info, type, name)
        self.planName = name
        self.typeName = type
        self.warmups = warmups
        self.cycles = cycles
        self.deloads = deloads  // by time
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? BaseCyclicPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                warmups == savedPlan.warmups &&
                cycles == savedPlan.cycles
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.cycles = store.getObjArray("cycles")
        self.deloads = store.getDblArray("deloads")
        
        if store.hasKey("typeName") {
            self.typeName = store.getStr("typeName")
        } else {
            self.typeName = "MastersBasicCyclePlan"
        }
        
        if store.hasKey("warmups") {
            self.warmups = store.getObj("warmups")
        } else {
            self.warmups = Warmups(withBar: 2, firstPercent: 0.5, lastPercent: 0.9, reps: [5, 3, 1, 1, 1])
        }
        
        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.sets = store.getObjArray("sets")
        self.maxWeight = store.getDbl("maxWeight")
        self.setIndex = store.getInt("setIndex", ifMissing: 0)
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
                maxWeight = 0.0
                state = .waiting
            }
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addObj("warmups", warmups)
        store.addObjArray("cycles", cycles)
        store.addDblArray("deloads", deloads)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addObjArray("sets", sets)
        store.addDbl("maxWeight", maxWeight)
        store.addInt("setIndex", setIndex)
        store.addDate("modifiedOn", modifiedOn)
        store.addObj("state", state)
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    public var state = PlanState.waiting
    
    public func clone() -> Plan {
        frontend.assert(false, "abstract method")
        abort()
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting %@ for %@ and %@", type: .info, typeName, planName, exerciseName)
        
        self.sets = []
        self.setIndex = 0
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet
        
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if setting.weight == 0.0 {
                self.state = .blocked
                return NRepMaxPlan("Rep Max", workReps: cycles.first?.workReps ?? 5)
            }
            
            doBuildSets(setting)
            self.state = .started
            frontend.saveExercise(exerciseName)
            return nil
            
        case .left(let err):
            self.state = .error(err)
            return nil
        }
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
                doBuildSets(setting)
            }
        case .left(_):
            break
        }
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            let cycleIndex = BaseCyclicPlan.getCycle(cycles, history)
            let cycle = cycles[cycleIndex]
            let sr = "\(cycle.workSets)x\(cycle.workReps)"
            
            let info1 = Weight(maxWeight, apparatus).closest()
            if cycle.percent == 1.0 {
                return "\(sr) @ \(info1.text)"
            } else {
                let info2 = sets.last!.weight
                let p = String(format: "%.0f", 100.0*cycle.percent)
                return "\(sr) @ \(info2.text) (\(p)% of \(info1.text))"
            }
            
        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> String {
        if let deload = doDeloadByTime(), let percent = deload.percent {
            return "Deloaded by \(percent)% (last was \(deload.weeks) ago)"
        } else {
            let index = BaseCyclicPlan.getCycle(cycles, history)
            let results = history.filter {$0.cycleIndex == index}
            return makePrevLabel(results)
        }
    }
    
    public func historyLabel() -> String {
        let index = BaseCyclicPlan.getCycle(cycles, history)
        let results = history.filter {$0.cycleIndex == index}
        var weights = Array(results.map {$0.getWeight()})
        if case .right(let apparatus) = findApparatus(exerciseName) {
            if let deload = doDeloadByTime() {
                let workingSetWeight = getWorkingSetWeight(deload, log: false)
                let info = Weight(workingSetWeight, apparatus).closest()
                weights.append(info.weight)
            }
        }
        
        return makeHistoryLabel(weights)
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
    
    // Note that this is called after advancing.
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: !sets[setIndex].warmup, secs: secs)
            
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func description() -> String {
        frontend.assert(false, "abstract method")
        abort()
    }
    
    /// TODO: Think we can have a global that just does this.
    public func currentWeight() -> Double? {
        if case .right(let apparatus) = findApparatus(exerciseName) {
            if let deload = doDeloadByTime() {
                let info = Weight(deload.weight, apparatus).closest()
                return info.weight
            }
        }
        
        return nil
    }
    
    public func reset() {
        setIndex = 0
        modifiedOn = Date()
        state = .started
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func completions() -> Completions {
        if setIndex+1 < sets.count {
            return .normal([Completion(title: "", isDefault: true, callback: {self.doNext()})])
        } else {
            return getFinishingCompletions()
        }
    }
    
    // Internal items
    internal func getFinishingCompletions() -> Completions {
        frontend.assert(false, "abstract method")
        abort()
    }
    
    internal static func findCycleResult(_ history: [Result], _ index: Int) -> Result? {
        for candidate in history.reversed() {
            if candidate.cycleIndex == index {
                return candidate
            }
        }
        return nil
    }
    
    internal func addResult(_ cycleIndex: Int, _ missed: Bool) {
        let weight = sets.last!.weight
        let numSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let numReps = sets.filter({!$0.warmup}).map({$0.numReps}).min() ?? 0    // min so 531 does something sensible
        let result = Result(numSets, numReps,  cycleIndex, missed, weight)
        history.append(result)
    }
    
    internal static func getCycle(_ cycles: [Execute], _ history: [Result]) -> Int {
        if let last = history.last {
            return (last.cycleIndex + 1) % cycles.count
        } else {
            return 0
        }
    }
    
    internal func getWorkingSetWeight(_ deload: Deload, log: Bool) -> Double {
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        
        var workingSetWeight = cycle.percent*deload.weight
        if let percent = deload.percent {
            if log {
                os_log("deloaded by %d%% (last was %d weeks ago)", type: .info, percent, deload.weeks)
            }
        } else if let result = MastersBasicCyclePlan.findCycleResult(history, cycleIndex), result.missed {
            if let weight = getMissedWeight(cycleIndex, result) {
                workingSetWeight = weight
                if log {
                    os_log("using %.3f (previous cycle was missed)", type: .info, weight)
                }
            }
        }
        return workingSetWeight
    }
    
    internal func getMissedWeight(_ cycleIndex: Int, _ result: Result) -> Double? {
        return nil
    }
    
    // Private items
    private func doNext() {
        setIndex += 1
        modifiedOn = Date()
        state = .underway
        frontend.saveExercise(exerciseName)
    }
    
    private func doBuildSets(_ setting: VariableWeightSetting) {
        let cycleIndex = BaseCyclicPlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
        self.maxWeight = deload.weight
        
        let workingSetWeight = getWorkingSetWeight(deload, log: true)
        os_log("workingSetWeight = %.3f", type: .info, workingSetWeight)
        
        self.sets = []
        
        let warmupSets = warmups.computeWarmups(setting.apparatus, workingSetWeight: workingSetWeight)
        for (reps, setIndex, percent, warmupWeight) in warmupSets {
            sets.append(Set(setting.apparatus, phase: setIndex, phaseCount: warmupSets.count, numReps: reps, percent: percent, warmupWeight: warmupWeight, workingSetWeight: workingSetWeight))
        }
        
        for i in 0..<cycle.workSets {
            sets.append(Set(setting.apparatus, phase: i+1, phaseCount: cycle.workSets, numReps: cycle.workReps, workingSetWeight: workingSetWeight))
        }
    }
    
    private func doDeloadByTime() -> Deload? {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
            return deload
            
        case .left(_):
            return nil
        }
    }
    
    internal let warmups: Warmups
    internal let cycles: [Execute]
    internal let deloads: [Double]
    
    internal var modifiedOn = Date.distantPast
    internal var workoutName: String = ""
    internal var exerciseName: String = ""
    internal var history: [Result] = []
    internal var sets: [Set] = []
    internal var maxWeight: Double = 0.0
    internal var setIndex = 0
}

