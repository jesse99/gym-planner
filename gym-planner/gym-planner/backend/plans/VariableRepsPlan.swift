/// Advances reps but weight is controlled via options.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class VariableRepsPlan : Plan {
    struct Set: Storable {
        let title: String      // "Set 3 of 4"
        let amount: String
        
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
    
    struct Result: VariableWeightResult, Storable {
        let title: String   // "3x5 @ 135 lbs"
        let date: Date
        var weight: Double
        
        var primary: Bool {get {return true}}
        var missed: Bool {get {return false}}
        
        init(numSets: Int, numReps: Int, weight: Double) {
            if weight > 0.0 {
                self.title = "\(numSets)x\(numReps) @ \(Weight.friendlyUnitsStr(weight, plural: true))"
            } else {
                self.title = "\(numSets)x\(numReps)"
            }
            self.date = Date()
            self.weight = weight
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.date = store.getDate("date")
            self.weight = store.getDbl("weight")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addDate("date", date)
            store.addDbl("weight", weight)
        }
    }
    
    init(_ name: String, numSets: Int, minReps: Int, maxReps: Int) {
        os_log("init VariableRepsPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "VariableRepsPlan"
        self.numSets = numSets
        self.minReps = minReps
        self.maxReps = maxReps
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
        
        let savedOn = store.getDate("savedOn", ifMissing: Date.distantPast)
        let calendar = Calendar.current
        if !calendar.isDate(savedOn, inSameDayAs: Date()) && !sets.isEmpty {
            sets = []
            setIndex = 0
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
        store.addDate("savedOn", Date())
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: VariableRepsPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> StartResult {
        os_log("starting VariableRepsPlan for %@ and %@", type: .info, planName, exerciseName)
        self.sets = []
        self.setIndex = 0
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            buildSets(setting)
            frontend.saveExercise(exerciseName)
            return .ok
            
        case .left(let err):
            return .error(err)
        }
    }
    
    public func refresh() {
        switch findVariableRepsSetting(exerciseName) {
        case .right(let setting):
            buildSets(setting)
        case .left(_):
            break
        }
    }
    
    public func isStarted() -> Bool {
        return !sets.isEmpty && !finished()
    }
    
    public func underway(_ workout: Workout) -> Bool {
        return isStarted() && setIndex > 0 && workout.name == workoutName
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
    
    public func prevLabel() -> String {
        if let last = history.last {
            return last.title
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        if let last = history.last, last.weight > 0.0 {
            let weights = history.map {$0.weight}
            return makeHistoryLabel(Array(weights))
        } else {
            return ""
        }
    }
    
    public func current() -> Activity {
        frontend.assert(!finished(), "VariableRepsPlan is finished in current")
        
        return Activity(
            title: sets[setIndex].title,
            subtitle: "target is \(maxReps) reps",
            amount: sets[setIndex].amount,
            details: "",
            buttonName: "Next",
            showStartButton: true)
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: !finished() && setIndex > 0, secs: secs)
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func completions() -> [Completion] {
        if setIndex+1 < sets.count {
            return [Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})]
        } else {
            if case .right(let setting) = findVariableRepsSetting(exerciseName), setting.requestedReps < maxReps {
                return [
                    // TODO: What we need to do instead is prompt the user to see if he wants to add or remove reps.
                    // But we need to make sure he doesn't go beyond min and maxReps.
                    Completion(title: "Finished OK",  isDefault: true,  callback: {() -> Void in self.doFinish(false)}),
                    Completion(title: "Missed a rep", isDefault: false, callback: {() -> Void in self.doFinish(true)})]

            } else {
                return [Completion(title: "Done", isDefault: false, callback: {() -> Void in self.doFinish(false)})]
            }
        }
    }
    
    public func atStart() -> Bool {
        return setIndex == 0
    }
    
    public func finished() -> Bool {
        return setIndex == sets.count
    }
    
    public func reset() {
        setIndex = 0
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "In this plan weights are advanced each time the lifter successfully completes an exercise. If the lifter fails to do all reps three times in a row then the weight is reduced by 10%. This plan is used by beginner programs like StrongLifts."
    }
    
    public func findLastWeight() -> Double? {
        return history.last?.weight
    }
    
    // Internal items
    private func doNext() {
        setIndex += 1
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish(_ stalled: Bool) {
        setIndex += 1
        frontend.assert(finished(), "VariableRepsPlan is not finished in doFinish")
        
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }

        // TODO: handle advancing
        addResult()
        frontend.saveExercise(exerciseName)
    }
    
//    private func handleAdvance(_ missed: Bool) {
//        switch findVariableRepsSetting(exerciseName) {
//        case .right(let setting):
//            if !missed {
//                let old = setting.weight
//                let w = Weight(setting.weight, setting.apparatus)
//                setting.changeWeight(w.nextWeight())
//                setting.stalls = 0
//                os_log("advanced from %.3f to %.3f", type: .info, old, setting.weight)
//
//            } else {
//                setting.sameWeight()
//                setting.stalls += 1
//                os_log("stalled = %dx", type: .info, setting.stalls)
//
//                if setting.stalls >= 3 {
//                    let info = Weight(0.9*setting.weight, setting.apparatus).closest(below: setting.weight)
//                    setting.changeWeight(info.weight)
//                    setting.stalls = 0
//                    os_log("deloaded to = %.3f", type: .info, setting.weight)
//                }
//            }
//
//        case .left(let err):
//            // Not sure if this can happen, maybe if the user edits the program after the plan starts.
//            os_log("%@ advance failed: %@", type: .error, planName, err)
//            setIndex = sets.count
//        }
//    }
    
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
    
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var sets: [Set] = []
    private var history: [Result] = []
    private var setIndex: Int = 0
}



