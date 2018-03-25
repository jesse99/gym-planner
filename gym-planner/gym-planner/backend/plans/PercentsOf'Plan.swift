/// Plan that uses a percent of the weight from another plan.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class PercentsOfPlan : Plan {
    struct Set: Storable {
        let title: String      // "Set 3 of 4"
        let subtitle: String   // "90% of 140 lbs"
        let numReps: Int
        let weight: Weight.Info
        let amrap: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, workingSetWeight: Double, percent: Double, amrap: Bool) {
            self.title = "Set \(phase) of \(phaseCount)"
            self.weight = Weight(percent*workingSetWeight, apparatus).closest()
            self.numReps = numReps
            self.amrap = amrap
            
            let info = Weight(workingSetWeight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.subtitle = store.getStr("subtitle")
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
    
    struct WorkSet: Storable {
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
        
        init(from store: Store) {
            self.reps = store.getInt("reps")
            self.percent = store.getDbl("percent")
            self.amrap = store.getBool("amrap")
        }
        
        func save(_ store: Store) {
            store.addInt("reps", reps)
            store.addDbl("percent", percent)
            store.addBool("amrap", amrap)
        }
    }
    
    class Result: WeightedResult {
        init(_ weight: Weight.Info) {
            let title = weight.text
            super.init(title, weight.weight, primary: true, missed: false)
        }
        
        required init(from store: Store) {
            super.init(from: store)
        }
        
        internal override func updatedWeight(_ newWeight: Weight.Info) {
            title = newWeight.text
        }
    }

    init(_ name: String, _ workSets: [WorkSet], workSetPercent: Double) {
        os_log("init PercentsOfPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "PercentsOfPlan"
        self.workSets = workSets
        self.workSetPercent = workSetPercent
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
        if let savedPlan = inPlan as? PercentsOfPlan {
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
        self.typeName = "PercentsOfPlan"
        self.workSets = store.getObjArray("workSets")
        self.workSetPercent = store.getDbl("workSetPercent")

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
        store.addObjArray("workSets", workSets)
        store.addDbl("workSetPercent", workSetPercent)
        
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
        let result: PercentsOfPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting PercentsOfPlan for %@ and %@", type: .info, planName, exerciseName)
        
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
        return ""
    }
    
    public func prevLabel() -> String {
        if let result = history.last {
            return "Previous was \(Weight.friendlyUnitsStr(result.getWeight()))"
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        var weights = Array(history.map {$0.getWeight()})
        if case .right(let apparatus) = findApparatus(exerciseName) {
            if case .right(let otherWeight) = getOtherWeight() {
                let current = Weight(otherWeight, apparatus).closest(below: otherWeight)
                weights.append(current.weight)
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
        return "Similar to PercentOfPlan but it supports AMRAP sets and doesn't distinguish between warmup and work sets."
    }
    
    public func currentWeight() -> Double? {
        switch getOtherWeight() {
        case .right(let otherWeight):
            return otherWeight
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
        if let max_set = sets.max(by: {$0.weight.weight < $1.weight.weight}) {
            let result = Result(max_set.weight)
            history.append(result)
        }
    }
    
    private func buildSets(_ apparatus: Apparatus, _ otherWeight: Double) {
        let weight = otherWeight
        os_log("weight = %.3f", type: .info, weight)
        
        sets = []
        for (i, set) in workSets.enumerated() {
            sets.append(Set(apparatus, phase: i+1, phaseCount: workSets.count, numReps: set.reps, workingSetWeight: weight, percent: set.percent, amrap: set.amrap))
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
    
    private let workSets: [WorkSet]
    private let workSetPercent: Double

    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex: Int = 0
}

extension PercentsOfPlan.WorkSet: Equatable {}

func ==(lhs: PercentsOfPlan.WorkSet, rhs: PercentsOfPlan.WorkSet) -> Bool {
    return lhs.reps == rhs.reps && lhs.percent == rhs.percent && lhs.amrap == rhs.amrap
}

