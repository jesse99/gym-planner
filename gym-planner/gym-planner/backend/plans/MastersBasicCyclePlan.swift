/// N (typically three) week cycle where reps drop and weight goes up. Progression happens after the
/// last cycle if the first cycle went OK.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

// 4x5 @ 100%, 4x3 @ 105%, 4x1 @ 110%

// TODO: Might want a version of this for younger people: less warmup sets, no rest on last warmup, less deload by time, less weight on medium/light days
public class MastersBasicCyclePlan : Plan, CustomDebugStringConvertible {
    struct Execute: Storable, Equatable, CustomDebugStringConvertible {
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

        var debugDescription: String {
            return "\(workSets)x\(workReps) @ \(Int(100.0*percent))"
        }
    }

    struct Set: Storable, CustomDebugStringConvertible {
        let title: String      // "Workset 3 of 4"
        let subtitle: String   // "90% of 140 lbs"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = Weight(percent*weight, apparatus).closest(below: weight)
            self.numReps = numReps
            self.warmup = true

            let info1 = Weight(weight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info1.text)"
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

        var debugDescription: String {
            return title
        }
    }
    
    class Result: WeightedResult {
        let cycleIndex: Int

        init(title: String, cycleIndex: Int, missed: Bool, weight: Double) {
            self.cycleIndex = cycleIndex
            super.init(title, weight, primary: cycleIndex == 0, missed: missed)
        }
        
        required init(from store: Store) {
            self.cycleIndex = store.getInt("cycleIndex")
            super.init(from: store)
        }
        
        override func save(_ store: Store) {
            super.save(store)
            store.addInt("cycleIndex", cycleIndex)
        }
    }
    
    init(_ name: String, _ cycles: [Execute]) {
        os_log("init MastersBasicCyclePlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "MastersBasicCyclePlan"
        self.cycles = cycles
        self.deloads = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.9, 0.85, 0.8]
//        self.deloads = [1.0, 1.0, 0.9, 0.85, 0.8]
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? MastersBasicCyclePlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                cycles == savedPlan.cycles
        } else {
            return false
        }
    }

    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "MastersBasicCyclePlan"
        self.cycles = store.getObjArray("cycles")
        self.deloads = store.getDblArray("deloads")
        
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

    public var debugDescription: String {
        return planName
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    public var state = PlanState.waiting

    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: MastersBasicCyclePlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting MastersBasicCyclePlan for %@ and %@", type: .info, planName, exerciseName)
        
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
            
            buildSets(setting)
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
        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
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
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
            if let percent = deload.percent {
                return "Deloaded by \(percent)% (last was \(deload.weeks) ago)"
                
            } else {
                let index = MastersBasicCyclePlan.getCycle(cycles, history)
                let results = history.filter {$0.cycleIndex == index}
                return makePrevLabel(results)
            }

        case .left(_):
            return ""
        }
    }
    
    public func historyLabel() -> String {
        let index = MastersBasicCyclePlan.getCycle(cycles, history)
        let results = history.filter {$0.cycleIndex == index}
        let weights = results.map {$0.weight}
        return makeHistoryLabel(Array(weights))
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
            if case .finished = state {
                return RestTime(autoStart: true, secs: secs)   // TODO: make this an option?
            } else if setIndex > 0 && sets[setIndex-1].warmup && !sets[setIndex].warmup {
                return RestTime(autoStart: true, secs: secs/2)
            } else if !sets[setIndex].warmup {
                return RestTime(autoStart: true, secs: secs)
            } else {
                return RestTime(autoStart: false, secs: secs)
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
        return "This is designed for lifters in their 40s and 50s. Typically it's used with three week cycles where the first week is sets of five, the second week sets of three, and the third week sets of one with the second week using 5% more weight and the third week 10% more weight. If all reps were completed for the sets of five then the weight is increased after the third week."
    }
    
    /// TODO: Think we can have a global that just does this.
    public func currentWeight() -> Double? {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
            return deload.weight

        case .left(_):
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
        
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        addResult(cycleIndex, missed)
        
        if cycleIndex == cycles.count-1 {
            handleAdvance()
        } else {
            handleConstant()
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func handleAdvance() {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if let result = MastersBasicCyclePlan.findCycleResult(history, 0) {
                if !result.missed {
                    let old = setting.weight
                    let w = Weight(old, setting.apparatus)
                    setting.changeWeight(w.nextWeight())
                    setting.stalls = 0
                    os_log("advanced from %.3f to %.3f", type: .info, old, setting.weight)
                    
                } else {
                    setting.sameWeight()
                    setting.stalls += 1
                    os_log("stalled = %d", type: .info, setting.stalls)
                }
            }
            
        case .left(_):
            break
        }
    }
    
    private func handleConstant() {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            // We're on a cycle where the weights don't advance but we still need to indicate that
            // we've done a lift so that deload by time doesn't kick in.
            setting.sameWeight()
        case .left(_):
            break
        }
    }
    
    private static func findCycleResult(_ history: [Result], _ index: Int) -> Result? {
        for candidate in history.reversed() {
            if candidate.cycleIndex == index {
                return candidate
            }
        }
        return nil
    }

    private func addResult(_ cycleIndex: Int, _ missed: Bool) {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, cycleIndex: cycleIndex, missed: missed, weight: sets.last!.weight.weight)
        history.append(result)
    }
    
    private func buildSets(_ setting: VariableWeightSetting) {
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        let cycle = cycles[cycleIndex]
        
        let deload = deloadByDate(setting.weight, setting.updatedWeight, deloads)
        self.maxWeight = deload.weight
        
        var workingSetWeight = cycle.percent*self.maxWeight
        if let percent = deload.percent {
            os_log("deloaded by %d%% (last was %d weeks ago)", type: .info, percent, deload.weeks)
        } else if let result = MastersBasicCyclePlan.findCycleResult(history, cycleIndex), cycleIndex > 0 && result.missed {    // missed first cycle is dealt with in handleAdvance
            os_log("using previous weight since this cycle was missed last time", type: .info)
            workingSetWeight = result.weight
        }
        os_log("workingSetWeight = %.3f", type: .info, workingSetWeight)
        
        var warmupsWithBar = 0
        switch setting.apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
        default: break
        }
        
        self.sets = []
        
        let numWarmups = 5 + warmupsWithBar
        for i in 0..<warmupsWithBar {
            sets.append(Set(setting.apparatus, phase: i+1, phaseCount: numWarmups, numReps: 5, percent: 0.0, weight: workingSetWeight))   // could also use max reps from all the executes, but 5 is probably better than 10 or whatever
        }
        
        sets.append(Set(setting.apparatus, phase: numWarmups-4, phaseCount: numWarmups, numReps: 5, percent: 0.5, weight: workingSetWeight))
        sets.append(Set(setting.apparatus, phase: numWarmups-3, phaseCount: numWarmups, numReps: 3, percent: 0.6, weight: workingSetWeight))
        sets.append(Set(setting.apparatus, phase: numWarmups-2, phaseCount: numWarmups, numReps: 1, percent: 0.7, weight: workingSetWeight))
        sets.append(Set(setting.apparatus, phase: numWarmups-1, phaseCount: numWarmups, numReps: 1, percent: 0.8, weight: workingSetWeight))
        sets.append(Set(setting.apparatus, phase: numWarmups,   phaseCount: numWarmups, numReps: 1, percent: 0.9, weight: workingSetWeight))
        frontend.assert(sets.count == numWarmups, "MastersBasicCyclePlan sets.count is \(sets.count) but numWarmups is \(numWarmups)")
        
        for i in 0..<cycle.workSets {
            sets.append(Set(setting.apparatus, phase: i+1, phaseCount: cycle.workSets, numReps: cycle.workReps, weight: workingSetWeight))
        }
    }

    private static func getCycle(_ cycles: [Execute], _ history: [Result]) -> Int {
        if let last = history.last {
            return (last.cycleIndex + 1) % cycles.count
        } else {
            return 0
        }
    }

    private let cycles: [Execute]
    private let deloads: [Double]
    
    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var maxWeight: Double = 0.0
    private var setIndex = 0
}
