/// Plan that uses a percent of the weight from another plan.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class PercentOfPlan : Plan {
    struct Set: Storable {
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
        init(title: String, weight: Double) {
            super.init(title, weight, primary: true, missed: false)
        }
        
        required init(from store: Store) {
            super.init(from: store)
        }
    }
    
    init(_ name: String, firstWarmup: Double, warmupReps: [Int], workSets: Int, workReps: Int, percent: Double) {
        os_log("init PercentOfPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "PercentOfPlan"
        self.firstWarmup = firstWarmup
        self.warmupReps = warmupReps
        self.workSets = workSets
        self.workReps = workReps
        self.percent = percent
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? PercentOfPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                firstWarmup == savedPlan.firstWarmup &&
                warmupReps == savedPlan.warmupReps &&
                workSets == savedPlan.workSets &&
                workReps == savedPlan.workReps &&
                percent == savedPlan.percent
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "PercentOfPlan"
        self.firstWarmup = store.getDbl("firstWarmup")
        self.warmupReps = store.getIntArray("warmupReps")
        self.workSets = store.getInt("workSets")
        self.workReps = store.getInt("workReps")
        self.percent = store.getDbl("percent")
        
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
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
        store.addDbl("firstWarmup", firstWarmup)
        store.addIntArray("warmupReps", warmupReps)
        store.addInt("workSets", workSets)
        store.addInt("workReps", workReps)
        store.addDbl("percent", percent)

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
        let result: PercentOfPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting PercentOfPlan for %@ and %@", type: .info, planName, exerciseName)

        self.sets = []
        self.setIndex = 0
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet

        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            switch getOtherWeight() {
            case .right(let otherWeight):
                self.state = .started
                buildSets(apparatus, otherWeight)
                frontend.saveExercise(exerciseName)

            case .left(let err):
                self.state = .error(err)
            }
            
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
        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            switch getOtherWeight() {
            case .right(let otherWeight):
                buildSets(apparatus, otherWeight)
            case .left(_):
                break
            }
            
        case .left(_):
            break
        }
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        var suffix = ""
        switch getOtherWeight() {
        case .right(let otherWeight):
            suffix = "'s \(Weight.friendlyUnitsStr(otherWeight, plural: true))"
        case .left(_):
            break
        }
        
        switch findBaseExerciseName(exerciseName) {
            case .right(let otherName):
                if let weight = sets.last?.weight {
                    let p = Int(100.0*self.percent)
                    return "\(weight.text) (\(p)% of \(otherName)\(suffix))"
                
                } else {
                    let p = Int(100.0*self.percent)
                    return "\(p)% of \(otherName)\(suffix)"
                }

            case .left(let err):
                return err
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
            return .normal([Completion(title: "Done", isDefault: false, callback: {() -> Void in self.doFinish()})])
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
        return "This does an exercise at a percentage of another exercises workset. It's typically used to perform a light or medium version of another exercise."
    }
    
    public func currentWeight() -> Double? {
        switch getOtherWeight() {
        case .right(let otherWeight):
            return percent*otherWeight
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
    
    private func doFinish() {
        modifiedOn = Date()
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        addResult()
        frontend.saveExercise(exerciseName)
    }
    
    private func addResult() {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, weight: sets.last!.weight.weight)
        history.append(result)
    }
    
    private func buildSets(_ apparatus: Apparatus, _ otherWeight: Double) {
        let workingSetWeight = percent*otherWeight
        os_log("workingSetWeight = %.3f", type: .info, workingSetWeight)
        
        var warmupsWithBar = 0
        switch apparatus {
        case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
        default: break
        }
        
        sets = []
        let numWarmups = warmupsWithBar + warmupReps.count
        for i in 0..<warmupsWithBar {
            sets.append(Set(apparatus, phase: i+1, phaseCount: numWarmups, numReps: warmupReps.first ?? 5, percent: 0.0, weight: workingSetWeight))
        }
        
        let delta = warmupReps.count > 0 ? (0.9 - firstWarmup)/Double(warmupReps.count - 1) : 0.0
        for (i, reps) in warmupReps.enumerated() {
            let percent = firstWarmup + Double(i)*delta
            sets.append(Set(apparatus, phase: warmupsWithBar + i + 1, phaseCount: numWarmups, numReps: reps, percent: percent, weight: workingSetWeight))
        }
        
        for i in 0..<workSets {
            sets.append(Set(apparatus, phase: i+1, phaseCount: workSets, numReps: workReps, weight: workingSetWeight))
        }
    }
    
    private func getOtherWeight() -> Either<String, Double> {
        // We do this bit just so that we can produce a better error message for the user.
        switch findBaseExerciseName(exerciseName) {
        case .right(let otherName):
            switch findExercise(otherName) {
            case .right(let otherExercise):
                let p = otherExercise.plan.clone()
                if let workout = frontend.findWorkout(workoutName) {
                    _ = p.start(workout, otherName)
                    switch p.state {
                    case .blocked:
                        return .left("Execute \(otherName) first")
                    case .error(let err):
                        return .left(err)
                    default:
                        // We want to use whatever the user last lifted,
                        if let weight = p.currentWeight() {
                            return .right(weight)
                        } else {
                            // but if all they have run is NRepsMax then we'll settle for what they should lift next time.
                            os_log("falling back onto settings weight for %@", type: .info, otherName)
                            return findCurrentWeight(otherName)
                        }
                    }
                } else {
                    return .left("Couldn't find workout \(workoutName)")
                }
            case .left(let err):
                return .left(err)
            }
            
        case .left(let err):
            return .left(err)
        }
    }
    
    private let firstWarmup: Double
    private let warmupReps: [Int]
    private let workSets: Int;
    private let workReps: Int
    private let percent: Double

    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex: Int = 0
}
