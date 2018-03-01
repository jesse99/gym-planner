/// Base class for plans where the reps and percentages change each workout.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class BaseCyclicPlan : Plan {
    struct Reps: Storable, Equatable {
        let count: Int
        let percent: Double
        let amrap: Bool
        
        init(count: Int, percent: Double, amrap: Bool = false) {
            self.count = count
            self.percent = percent
            self.amrap = amrap
        }
        
        init(from store: Store) {
            self.count = store.getInt("count")
            self.percent = store.getDbl("percent")
            self.amrap = store.getBool("amrap")
        }
        
        func save(_ store: Store) {
            store.addInt("count", count)
            store.addDbl("percent", percent)
            store.addBool("amrap", amrap)
        }
        
        static func ==(lhs: Reps, rhs: Reps)->Bool {
            return lhs.count == rhs.count && lhs.percent == rhs.percent && lhs.amrap == rhs.amrap
        }
    }
    
    public struct Cycle: Storable, Equatable {
        let warmups: Warmups
        let worksets: [Reps]

        init(_ warmups: Warmups, _ worksets: [Reps]) {
            self.warmups = warmups
            self.worksets = worksets
        }
        
        init(withBar: Int, firstPercent: Double, lastPercent: Double, warmups: [Int], sets: Int, reps: Int, at: Double) {
            let warmups = Warmups(withBar: withBar, firstPercent: firstPercent, lastPercent: lastPercent, reps: warmups)
            let reps = Array(repeating: BaseCyclicPlan.Reps(count: reps, percent: at), count: sets)
            self.init(warmups, reps)
        }
        
        init(withBar: Int, firstPercent: Double, warmups: [Int], sets: Int, reps: Int, at: Double) {
            let warmups = Warmups(withBar: withBar, firstPercent: firstPercent, lastPercent: at - 0.1, reps: warmups)
            let reps = Array(repeating: BaseCyclicPlan.Reps(count: reps, percent: at), count: sets)
            self.init(warmups, reps)
        }

        public init(from store: Store) {
            self.warmups = store.getObj("warmups")
            self.worksets = store.getObjArray("worksets")
        }
        
        public func save(_ store: Store) {
            store.addObj("warmups", warmups)
            store.addObjArray("worksets", worksets)
        }
        
        /// Returns a string like "3x5", or "3x5+", or "3+" for the sets at the maximum percent (so that
        /// we aren't counting ascending or backoff sets).
        func label() -> String {
            if let maxPercent = worksets.map({$0.percent}).max() {
                let sets = worksets.filter({$0.percent == maxPercent})
                let reps = sets.map({$0.count.description + ($0.amrap ? "+" : "")})
                if reps.count > 0 {
                    if reps.count == 1 {
                        return reps[0]
                    } else if reps.all({$0 == reps[0]}) {
                        return "\(reps.count)x\(reps[0])"
                    } else {
                        return "\(reps.first!) to \(reps.last!)"
                    }
                }
            }
            return ""
        }
        
        func maxPercent() -> Double {
            return worksets.map({$0.percent}).max() ?? 0.0
        }
        
        /// Returns the maximum number of reps at the maximum percent.
        func maxReps() -> Int {
            if let maxPercent = worksets.map({$0.percent}).max() {
                let sets = worksets.filter({$0.percent == maxPercent})
                let reps = sets.map({$0.count})
                return reps.max()!
            }
            return 0
        }
        
        static public func ==(lhs: Cycle, rhs: Cycle)->Bool {
            return lhs.warmups == rhs.warmups && lhs.worksets == rhs.worksets
        }
    }
    
    struct Set: Storable {
        let title: String      // "Workset 3 of 4"
        let subtitle: String   // "90% of 140 lbs"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        let amrap: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, warmupWeight: Weight.Info, unitWeight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = warmupWeight
            self.numReps = numReps
            self.warmup = true
            self.amrap = false
            
            let info = Weight(unitWeight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, workingPercent: Double, unitWeight: Double, amrap: Bool) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.weight = Weight(workingPercent*unitWeight, apparatus).closest()
            self.numReps = numReps
            self.warmup = false
            self.amrap = amrap

            if workingPercent == 1.0 {
                self.subtitle = ""
            } else {
                let info = Weight(unitWeight, apparatus).closest()
                let p = String(format: "%.0f", 100.0*workingPercent)
                self.subtitle = "\(p)% of \(info.text)"
            }
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.subtitle = store.getStr("subtitle")
            self.numReps = store.getInt("numReps")
            self.weight = store.getObj("weight")
            self.warmup = store.getBool("warmup")
            self.amrap = store.getBool("amrap", ifMissing: false)
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addStr("subtitle", subtitle)
            store.addInt("numReps", numReps)
            store.addObj("weight", weight)
            store.addBool("warmup", warmup)
            store.addBool("amrap", amrap)
        }
    }
    
    class Result: WeightedResult {
        init(_ label: String, _ cycleIndex: Int, _ missed: Bool, _ info: Weight.Info) {
            self.label = label
            self.cycleIndex = cycleIndex
            let title = "\(label) @ \(info.text)"
            super.init(title, info.weight, primary: cycleIndex == 0, missed: missed)
        }
        
        required init(from store: Store) {
            if store.hasKey("label") {
                self.label = store.getStr("label")
            } else {
                let numSets = store.getInt("numSets", ifMissing: 0)
                let numReps = store.getInt("numReps", ifMissing: 0)
                self.label = "\(numSets)x\(numReps)"
            }
            self.cycleIndex = store.getInt("cycleIndex")
            super.init(from: store)
        }
        
        override func save(_ store: Store) {
            super.save(store)
            store.addStr("label", label)
            store.addInt("cycleIndex", cycleIndex)
        }
        
        internal override func updatedWeight(_ newWeight: Weight.Info) {
            title = "\(label) @ \(newWeight.text)"
        }
        
        let label: String
        let cycleIndex: Int
    }
    
    init(_ name: String, _ type: String, _ cycles: [Cycle], deloads: [Double]) {
        os_log("init %@ for %@", type: .info, type, name)
        self.planName = name
        self.typeName = type
        self.cycles = cycles
        self.deloads = deloads  // by time
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? BaseCyclicPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                cycles == savedPlan.cycles &&
                deloads == savedPlan.deloads
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.deloads = store.getDblArray("deloads")
        
        if store.hasKey("cycles2") {
            self.cycles = store.getObjArray("cycles2")
        } else {
            let warmups = Warmups(withBar: 0, firstPercent: 0.5, lastPercent: 0.9, reps: [1])
            let reps = Reps(count: 5, percent: 1.0)
            self.cycles = [Cycle(warmups, [reps])]   // this will fail shouldSync so it won't actually be used
        }
        
        if store.hasKey("typeName") {
            self.typeName = store.getStr("typeName")
        } else {
            self.typeName = "MastersBasicCyclePlan"
        }
        
        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.sets = store.getObjArray("sets")
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
                state = .waiting
            }
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addObjArray("cycles2", cycles)
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
                let reps = cycles.first?.maxReps() ?? 5
                return NRepMaxPlan("Rep Max", workReps: reps)
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
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let index = BaseCyclicPlan.getCycle(cycles, history)
            let cycle = cycles[index]
            let sr = cycle.label()
            
            if setting.weight > 0.0 {
                let unitWeight = getUnitWeight(setting, log: false)
                let unitInfo = Weight(unitWeight, setting.apparatus).closest()
                
                let percent = cycle.maxPercent()
                if percent == 1.0 {
                    return "\(sr) @ \(unitInfo.text)"
                } else {
                    let maxWeight = percent*unitWeight
                    let maxInfo = Weight(maxWeight, setting.apparatus).closest()
                    let p = String(format: "%.0f", 100.0*percent)
                    return "\(sr) @ \(maxInfo.text) (\(p)% of \(unitInfo.text))"
                }
            }
            return sr

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
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let index = BaseCyclicPlan.getCycle(cycles, history)
            let results = history.filter {$0.cycleIndex == index}
            var weights = Array(results.map {$0.getWeight()})

            if setting.weight > 0.0 {
                let cycle = cycles[index]
                let percent = cycle.maxPercent()
                let weight = getUnitWeight(setting, log: false)
                let info = Weight(percent*weight, setting.apparatus).closest()
                weights.append(info.weight)
            }
            
            return makeHistoryLabel(weights)

        case .left(_):
            break
        }
        return ""
    }
    
    public func current() -> Activity {
        let info = sets[setIndex].weight
        let prefix = sets[setIndex].amrap ? "\(sets[setIndex].numReps)+ reps" : repsStr(sets[setIndex].numReps)
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: "\(prefix) @ \(info.text)",
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
    
    public func currentWeight() -> Double? {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if setting.weight > 0.0 {
                // We're supposed to return the "base-line weight" not the maxWeight for this particular workout.
                // So we'll just use the first cycle's weight.
                let cycle = cycles[0]
                let unitWeight = getUnitWeight(setting, log: false)
                return cycle.maxPercent()*unitWeight
            }
            
        case .left(_):
            break
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
        let weights = sets.map {$0.weight}
        let maxWeight = weights.max {$0.weight < $1.weight}

        let cycle = cycles[cycleIndex]
        let result = Result(cycle.label(), cycleIndex, missed, maxWeight!)
        history.append(result)
    }
    
    internal static func getCycle(_ cycles: [Cycle], _ history: [Result]) -> Int {
        if let last = history.last {
            return (last.cycleIndex + 1) % cycles.count
        } else {
            return 0
        }
    }
    
    /// Returns the weight that would be lifted at 1.0 percent.
    internal func getUnitWeight(_ setting: VariableWeightSetting, log: Bool) -> Double {
        var weight = setting.weight

        if let deload = doDeloadByTime(), let percent = deload.percent {
            weight = deload.weight
            if log {
                os_log("deloaded by %d%% (last was %d weeks ago)", type: .info, percent, deload.weeks)
            }
        } else if let adjustedWeight = adjustUnitWeight() {
            weight = adjustedWeight
            if log {
                os_log("using %.3f (adjusted)", type: .info, adjustedWeight)
            }
        }
        
        return weight
    }
    
    /// Override and optionally return a new weight for stuff like the last result was missed.
    internal func adjustUnitWeight() -> Double? {
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
        let index = BaseCyclicPlan.getCycle(cycles, history)
        let cycle = cycles[index]
        
        let unitWeight = getUnitWeight(setting, log: true)
        os_log("unitWeight = %.3f", type: .info, unitWeight)
        
        self.sets = []
        
        let warmupSets = cycle.warmups.computeWarmups(setting.apparatus, unitWeight: unitWeight)
        for (reps, setIndex, percent, warmupWeight) in warmupSets {
            sets.append(Set(setting.apparatus, phase: setIndex, phaseCount: warmupSets.count, numReps: reps, percent: percent, warmupWeight: warmupWeight, unitWeight: unitWeight))
        }
        
        for (i, reps) in cycle.worksets.enumerated() {
            sets.append(Set(setting.apparatus, phase: i+1, phaseCount: cycle.worksets.count, numReps: reps.count, workingPercent: reps.percent, unitWeight: unitWeight, amrap: reps.amrap))
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
    
    internal let cycles: [Cycle]
    internal let deloads: [Double]
    
    internal var modifiedOn = Date.distantPast
    internal var workoutName: String = ""
    internal var exerciseName: String = ""
    internal var history: [Result] = []
    internal var sets: [Set] = []
    internal var setIndex = 0
}

