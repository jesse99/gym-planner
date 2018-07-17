/// Sets and reps are fixed with an optional weight (set by the user).
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import UIKit
import os.log

public class FixedSetsPlan : Plan {
    class Result: WeightedResult {
        init(_ numSets: Int, _ numReps: Int, _ weight: Double) {
            self.numSets = numSets
            self.numReps = numReps
            
            var title = "\(numSets)x\(numReps)"
            if weight > 0.0 {
                title += " @ \(Weight.friendlyUnitsStr(weight, plural: true))"
            }

            super.init(title, weight, primary: true, missed: false)
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
            title = "\(numSets)x\(numReps)"
            if newWeight.weight > 0.0 {
                title += " @ \(newWeight.text)"
            }
        }
        
        let numSets: Int
        let numReps: Int
    }
    
    init(_ name: String, numSets: Int, numReps: Int) {
        os_log("init FixedSetsPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "FixedSetsPlan"
        self.numSets = numSets
        self.numReps = numReps
    }
    
    public func errors() -> [String] {
        var problems: [String] = []
        
        if numSets < 1 {
            problems += ["plan \(planName) numSets is less than 1"]
        }
        if numReps < 1 {
            problems += ["plan \(planName) numReps is less than 1"]
        }
        
        return problems
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? FixedSetsPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                numSets == savedPlan.numSets &&
                numReps == savedPlan.numReps
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "FixedSetsPlan"
        self.numSets = store.getInt("numSets")
        self.numReps = store.getInt("numReps")
        
        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.setIndex = store.getInt("setIndex")
        self.state = store.getObj("state", ifMissing: .waiting)
        self.modifiedOn = store.getDate("modifiedOn", ifMissing: Date.distantPast)

        switch state {
        case .waiting:
            break
        default:
            let calendar = Calendar.current
            if !calendar.isDate(modifiedOn, inSameDayAs: Date()) {
                setIndex = 1
                state = .waiting
            }
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addInt("numSets", numSets)
        store.addInt("numReps", numReps)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
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
        let result: FixedSetsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting FixedSetsPlan for %@ and %@", type: .info, planName, exerciseName)
        self.setIndex = 1
        self.state = .started
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet
        frontend.saveExercise(exerciseName)
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
        // nothing to do
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        switch findCurrentWeight(exerciseName) {
        case .right(let weight):
            if weight > 0.0 {
                return "\(numSets)x\(numReps) @ \(Weight.friendlyUnitsStr(weight, plural: true))"
            } else {
                return "\(numSets)x\(numReps)"
            }

        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> (String, UIColor) {
        if case let .right(weight) = findCurrentWeight(exerciseName), weight > 0.0 {
            return (makePrevLabel(history), UIColor.black)
        } else {
            return ("", UIColor.black)
        }
    }
    
    public func historyLabel() -> String {
        if case let .right(weight) = findCurrentWeight(exerciseName), weight > 0.0 {
            var weights = Array(history.map {$0.getWeight()})
            weights.append(weight)
            return makeHistoryLabel(weights)
        } else if !history.isEmpty {
            return "x\(history.count)"
        } else {
            return ""
        }
    }
    
    public func current() -> Activity {
        var suffix = ""
        if case let .right(weight) = findCurrentWeight(exerciseName), weight > 0.0 {
            suffix = " @ \(Weight.friendlyUnitsStr(weight, plural: true))"
        }

        return Activity(
            title: "Set \(setIndex) of \(numSets)",
            subtitle: "",
            amount: "\(repsStr(numReps))\(suffix)",
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
                return RestTime(autoStart: true, secs: secs)
            }
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }

    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func completions() -> Completions {
        if setIndex+1 < numSets {
            return .normal([Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})])
        } else {
            return .normal([Completion(title: "Done", isDefault: true, callback: {() -> Void in self.doFinish()})])
        }
    }
    
    public func reset() {
        setIndex = 1
        state = .started
        modifiedOn = Date()
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Sets and reps are fixed and weight can be set via the Options screen, e.g. 1x15 of shoulder dislocates."
    }
    
    public func currentWeight() -> Double? {
        switch findCurrentWeight(exerciseName) {
        case .right(let weight):
            return weight
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
        if case let .right(weight) = findCurrentWeight(exerciseName) {
            let result = Result(numSets, numReps, weight)
            history.append(result)
        } else {
            let result = Result(numSets, numReps, 0.0)
            history.append(result)
        }
    }
    
    private let numSets: Int
    private let numReps: Int

    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var setIndex = 1
}
