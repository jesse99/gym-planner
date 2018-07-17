/// Do sets for a specified amount of time.
import Foundation
import UIKit
import os.log

public class TimedPlan : Plan {
    class Result: WeightedResult {
        var numSets: Int
        var secs: Int

        init(_ numSets: Int, secs: Int, weight: Double) {
            self.numSets = numSets
            self.secs = secs
            let title = "\(numSets)% sets @ \(secsToStr(secs))"
            super.init(title, weight, primary: true, missed: false)
        }
        
        required init(from store: Store) {
            self.numSets = store.getInt("numSets", ifMissing: 0)
            self.secs = store.getInt("secs")
            super.init(from: store)
        }
        
        override func save(_ store: Store) {
            super.save(store)
            store.addInt("numSets", numSets)
            store.addInt("secs", secs)
        }
        
        internal override func updatedWeight(_ newWeight: Weight.Info) {
            title = "\(numSets)% sets @ \(secsToStr(secs))"
        }
    }
    
    init(_ name: String, numSets: Int, targetTime: Int?) {
        os_log("init TimedPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "TimedPlan"
        self.numSets = numSets
        self.targetTime = targetTime
    }
    
    public func errors() -> [String] {
        var problems: [String] = []
                
        if numSets < 1 {
            problems += ["plan \(planName) numSets is less than 1"]
        }
        if let target = targetTime, target < 0 {
            problems += ["plan \(planName) target is less than 0"]
        }
        
        return problems
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? TimedPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                numSets == savedPlan.numSets &&
                targetTime == savedPlan.targetTime
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "TimedPlan"
        self.numSets = store.getInt("numSets")

        let time = store.getInt("targetTime")
        if time != 0 {
            self.targetTime = time
        } else {
            self.targetTime = nil
        }
        
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
        store.addInt("targetTime", targetTime ?? 0)
        
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
        let result: TimedPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting TimedPlan for %@ and %@", type: .info, planName, exerciseName)
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
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return "\(numSets) sets @ \(secsToStr(secs))"
        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> (String, UIColor) {
        if let result = history.last {
            return ("Previous was \(secsToStr(result.secs))", UIColor.black)
        } else {
            return ("", UIColor.black)
        }
    }
    
    public func historyLabel() -> String {
        let labels = history.map {secsToStr($0.secs)}
        return makeHistoryFromLabels(labels)
    }
    
    public func current() -> Activity {
        var subtitle = ""
        if let target = targetTime {
            subtitle = "Target is \(secsToStr(target))"
        }
        
        var amount = ""
        if case let .right(weight) = findCurrentWeight(exerciseName), weight > 0.0 {
            amount = "\(Weight.friendlyUnitsStr(weight, plural: true))"
        }
        
        return Activity(
            title: "Set \(setIndex) of \(numSets)",
            subtitle: subtitle,
            amount: amount,
            details: "",
            buttonName: "Start",
            showStartButton: setIndex > 1,
            color: nil)
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: true, secs: secs)
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func restSound() -> UInt32 {
        return 1007       // see http://iphonedevwiki.net/index.php/AudioServices
    }
    
    public func completions() -> Completions {
        if setIndex+1 <= numSets {
            return .normal([Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})])
        } else {
            return .normal([Completion(title: "",  isDefault: true,  callback: {() -> Void in self.doFinish()})])
        }
    }
    
    public func reset() {
        setIndex = 1
        modifiedOn = Date()
        state = .started
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Do one or more sets for a period of time with an optional weight, e.g. 2x30s of a couch stretch."
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
        switch findFixedSetting(exerciseName) {
        case .right(let setting):
            let result = Result(numSets, secs: setting.restSecs, weight: setting.weight)
            history.append(result)

        case .left(_):
            break
        }
    }
    
    private let numSets: Int
    private let targetTime: Int?
    
    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var setIndex = 1
}
