/// Used for high intensity interval training.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import UIKit
import os.log

public class HIITPlan : Plan {
    enum Kind: Int {
        case warmup = 1
        case high
        case low
        case cooldown
    }
    
    struct Set: Storable {
        let title: String      // "High 3 of 4"
        let amount: String     // "level 5"
        let kind: Kind
        
        init(_ title: String, _ amount: String, _ kind: Kind) {
            self.title = title
            self.amount = amount
            self.kind = kind
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.amount = store.getStr("amount")
            self.kind = Kind(rawValue: store.getInt("kind"))!
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addStr("amount", amount)
            store.addInt("kind", kind.rawValue)
        }
    }
    
    class Result: BaseResult {
        let highSecs: Int
        let lowSecs: Int
        let numCycles: Int
        let highIntensity: String
        let lowIntensity: String
        
        init(_ highSecs: Int, _ lowSecs: Int, _ numCycles: Int, _ highIntensity: String, _ lowIntensity: String) {
            self.highSecs = highSecs
            self.lowSecs = lowSecs
            self.numCycles = numCycles
            
            self.highIntensity = highIntensity
            self.lowIntensity = lowIntensity
            
            super.init("\(numCycles) cycles of \(highSecs)x\(lowSecs)s")
        }
        
        required init(from store: Store) {
            self.highSecs = store.getInt("highSecs")
            self.lowSecs = store.getInt("lowSecs")
            self.numCycles = store.getInt("numCycles")
            self.highIntensity = store.getStr("highIntensity")
            self.lowIntensity = store.getStr("lowIntensity")

            super.init(from: store)
        }
        
        override func save(_ store: Store) {
            super.save(store)
            store.addInt("highSecs", highSecs)
            store.addInt("lowSecs", lowSecs)
            store.addInt("numCycles", numCycles)
            store.addStr("highIntensity", highIntensity)
            store.addStr("lowIntensity", lowIntensity)
        }
    }
    
    init(_ name: String, targetCycles: Int, targetHighSecs: Int) {
        os_log("init HIITPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "HIITPlan"
        self.targetCycles = targetCycles
        self.targetHighSecs = targetHighSecs
    }
    
    public func errors() -> [String] {
        var problems: [String] = []
        
        if targetCycles < 1 {
            problems += ["plan \(planName) targetCycles is less than 1"]
        }
        if targetHighSecs < 1 {
            problems += ["plan \(planName) targetHighSecs is less than 1"]
        }
        
        return problems
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? HIITPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                targetCycles == savedPlan.targetCycles &&
                targetHighSecs == savedPlan.targetHighSecs
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "HIITPlan"
        self.targetCycles = store.getInt("targetCycles")
        self.targetHighSecs = store.getInt("targetHighSecs")
        
        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
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
        store.addInt("targetCycles", targetCycles)
        store.addInt("targetHighSecs", targetHighSecs)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addDate("modifiedOn", modifiedOn)
        store.addObjArray("sets", sets)
        store.addInt("setIndex", setIndex)
        store.addObj("state", state)
    }
    
    // Plan methods
    public let planName: String
    public let typeName: String
    public var state = PlanState.waiting
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: HIITPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting HIITPlan for %@ and %@", type: .info, planName, exerciseName)
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.sets = []
        self.setIndex = 0
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet

        switch findHIITSetting(exerciseName) {
        case .right(let setting):
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
        switch findHIITSetting(exerciseName) {
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
        switch findHIITSetting(exerciseName) {
        case .right(let setting):
            return "\(setting.numCycles) cycles at \(setting.highSecs) and \(setting.lowSecs)s"
        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> (String, UIColor) {
        return ("Target is \(targetCycles) cycles with \(targetHighSecs)s at high", UIColor.black)
    }
    
    public func historyLabel() -> String {
        if !history.isEmpty {
            return "Worked out \(history.count) times"
        } else {
            return ""
        }
    }
    
    public func current() -> Activity {
        var color: String? = nil
        switch sets[setIndex].kind {
        case .high: color = "Salmon"
        case .low: color = "SkyBlue"
        default: break
        }
        
        return Activity(
            title: sets[setIndex].title,
            subtitle: "",
            amount: sets[setIndex].amount,
            details: "",
            buttonName: setIndex == 0 ? "Start" : "",
            showStartButton: true,
            color: color)
    }
    
    public func restSecs() -> RestTime {
        if case .finished = state {
            return RestTime(autoStart: false, secs: 0)
        }
        switch findHIITSetting(exerciseName) {
        case .right(let setting):
            switch sets[setIndex].kind {
            case .warmup: return RestTime(autoStart: true, secs: setting.warmupSecs)
            case .high: return RestTime(autoStart: true, secs: setting.highSecs)
            case .low: return RestTime(autoStart: true, secs: setting.lowSecs)
            case .cooldown: return RestTime(autoStart: true, secs: setting.cooldownSecs)
            }
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func restSound() -> UInt32 {
        if case .high = sets[setIndex].kind {
            return 1013       // bell, see http://iphonedevwiki.net/index.php/AudioServices
        } else {
            return 0
        }
    }
    
    public func completions() -> Completions {
        if setIndex+1 < sets.count {
            return .normal([Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})])
        } else {
            return .normal([Completion(title: "", isDefault: true, callback: {() -> Void in self.doFinish()})])
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
        return "Used for high intensity interval training, e.g. sprints."
    }
    
    public func currentWeight() -> Double? {
        return nil
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
        
        switch findHIITSetting(exerciseName) {
        case .right(let setting):
            let result = Result(setting.highSecs, setting.lowSecs, setting.numCycles, setting.highIntensity, setting.lowIntensity)
            history.append(result)
        case .left(_):
            break
        }
        
        frontend.saveExercise(exerciseName)
    }
    
    private func buildSets(_ setting: HIITSetting) {
        sets = []
        
        switch findHIITSetting(exerciseName) {
        case .right(let setting):
            sets.append(Set("Warmup", setting.warmupIntensity, .warmup))
            sets.append(Set("Warmup", setting.warmupIntensity, .warmup))    // start button enters this one
            
            for i in 0..<setting.numCycles {
                sets.append(Set("High \(i+1) of \(setting.numCycles)", setting.highIntensity, .high))
                sets.append(Set("Low \(i+1) of \(setting.numCycles)", setting.lowIntensity, .low))
            }

            sets.append(Set("Cooldown", setting.cooldownIntensity, .cooldown))
        case .left(_):
            break
        }
    }
    
    private let targetCycles: Int
    private let targetHighSecs: Int
    
    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex = 0
}

