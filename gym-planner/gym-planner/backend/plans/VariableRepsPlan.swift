/// Advances reps but weight is controlled via options.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import UIKit
import os.log

public class VariableRepsPlan : Plan {
    struct Set: Storable {
        let title: String      // "Set 3 of 4"
        let amount: String     // "3 reps @ 200 lbs"
        
        init(set: Int, numSets: Int, numReps: Int, weight: Double) {
            self.title = "Set \(set) of \(numSets)"
            if weight > 0.0 {
                self.amount = "\(repsStr(numReps)) @ \(Weight.friendlyUnitsStr(weight, plural: true))"
            } else {
                self.amount = repsStr(numReps)
            }
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.amount = store.getStr("amount", ifMissing: "")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addStr("amount", amount)
        }
    }
    
    class Result: WeightedResult {
        init(numSets: Int, numReps: Int, weight: Double) {
            self.numSets = numSets
            self.numReps = numReps

            if weight > 0.0 {
                let title = "\(numSets)x\(numReps) @ \(Weight.friendlyUnitsStr(weight, plural: true))"
                super.init(title, weight, primary: true, missed: false)
            } else {
                let title = "\(numSets)x\(numReps)"
                super.init(title, weight, primary: true, missed: false)
            }
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
            if newWeight.weight > 0.0 {
                title = "\(numSets)x\(numReps) @ \(newWeight.text)"
            } else {
                title = "\(numSets)x\(numReps)"
            }
        }
        
        let numSets: Int
        let numReps: Int
    }
    
    init(_ name: String, numSets: Int, minReps: Int, maxReps: Int) {
        os_log("init VariableRepsPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "VariableRepsPlan"
        self.numSets = numSets
        self.minReps = minReps
        self.maxReps = maxReps
    }
    
    public func errors() -> [String] {
        var problems: [String] = []
                
        if numSets < 1 {
            problems += ["plan \(planName) numSets is less than 1"]
        }
        if minReps < 1 {
            problems += ["plan \(planName) minReps is less than 1"]
        }
        if maxReps < 1 {
            problems += ["plan \(planName) maxReps is less than 1"]
        }
        
        if minReps > maxReps {
            problems += ["plan \(planName) minReps is greater than maxReps"]
        }

        return problems
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? VariableRepsPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                numSets == savedPlan.numSets &&
                minReps == savedPlan.minReps &&
                maxReps == savedPlan.maxReps
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "VariableRepsPlan"
        self.numSets = store.getInt("numSets")
        self.minReps = store.getInt("minReps")
        self.maxReps = store.getInt("maxReps")
        
        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.sets = store.getObjArray("sets")
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
        let result: VariableRepsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting VariableRepsPlan for %@ and %@", type: .info, planName, exerciseName)
        self.sets = []
        self.setIndex = 0
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet

        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
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
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            buildSets(setting)
        case .left(_):
            break
        }
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            if setting.weight > 0.0 {
                return "\(numSets)x\(setting.requestedReps) @ \(Weight.friendlyUnitsStr(setting.weight, plural: true))"
            } else {
                return "\(numSets)x\(setting.requestedReps)"
            }
        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> (String, UIColor) {
        if let last = history.last {
            return (last.title, UIColor.black)
        } else {
            return ("", UIColor.black)
        }
    }
    
    public func historyLabel() -> String {
        if let last = history.last, last.getWeight() > 0.0 {
            var weights = Array(history.map {$0.getWeight()})
            if case .right(let setting) = findVariableRepsSetting(exerciseName) {
                weights.append(setting.weight)
            }
            return makeHistoryLabel(weights)
        } else {
            return ""
        }
    }
    
    public func current() -> Activity {
        return Activity(
            title: sets[setIndex].title,
            subtitle: "target is \(maxReps) reps",
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
                return RestTime(autoStart: setIndex > 0, secs: secs)
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
            if case .right(let setting) = findVariableRepsSetting(exerciseName), setting.requestedReps < maxReps {
                var completions: [Completion] = []
                
                if setting.requestedReps+4 <= maxReps {
                    completions.append(Completion(title: "Add 4 Reps",  isDefault: false,  callback: {() -> Void in self.doFinish(4)}))
                }
                if setting.requestedReps+3 <= maxReps {
                    completions.append(Completion(title: "Add 3 Reps",  isDefault: false,  callback: {() -> Void in self.doFinish(3)}))
                }
                if setting.requestedReps+2 <= maxReps {
                    completions.append(Completion(title: "Add 2 Reps",  isDefault: false,  callback: {() -> Void in self.doFinish(2)}))
                }
                if setting.requestedReps+1 <= maxReps {
                    completions.append(Completion(title: "Add 1 Rep",  isDefault: false,  callback: {() -> Void in self.doFinish(1)}))
                }
                completions.append(Completion(title: "Done",  isDefault: true,  callback: {() -> Void in self.doFinish(0)}))
                if setting.requestedReps-1 >= minReps {
                    completions.append(Completion(title: "Subtract 1 Rep",  isDefault: false,  callback: {() -> Void in self.doFinish(-1)}))
                }
                if setting.requestedReps-2 >= minReps {
                    completions.append(Completion(title: "Subtract 2 Reps",  isDefault: false,  callback: {() -> Void in self.doFinish(-2)}))
                }
                return .normal(completions)

            } else {
                return .normal([Completion(title: "Done", isDefault: false, callback: {() -> Void in self.doFinish(0)})])
            }
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
        return "Do sets with reps where the reps can be adjusted after each workout. Includes an optional weight. Useful for exercises like dips."
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
    
    private func doFinish(_ addedReps: Int) {
        modifiedOn = Date()
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }

        if addedReps != 0 {
            handleAdvance(addedReps)
        }
        addResult()
        frontend.saveExercise(exerciseName)
    }
    
    private func handleAdvance(_ addedReps: Int) {
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            let old = setting.requestedReps
            setting.requestedReps += addedReps
            os_log("advanced from %d to %d reps", type: .info, old, setting.requestedReps)

        case .left(let err):
            // Not sure if this can happen, maybe if the user edits the program after the plan starts.
            os_log("%@ advance failed: %@", type: .error, planName, err)
        }
    }
    
    private func addResult() {
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            let result = Result(numSets: numSets, numReps: setting.requestedReps, weight: setting.weight)
            history.append(result)
        case .left(_):
            break
        }
    }
    
    private func buildSets(_ setting: VariableRepsSetting) {
        let weight = setting.weight
        os_log("weight = %.3f", type: .info, weight)
        
        sets = []
        for i in 0..<numSets {
            sets.append(Set(set: i+1, numSets: numSets, numReps: setting.requestedReps, weight: setting.weight))
        }
    }
    
    private let numSets: Int
    private let minReps: Int
    private let maxReps: Int
    
    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex = 0
}
