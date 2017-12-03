/// Do sets for a specified amount of time.
import Foundation
import os.log

public class TimedPlan : Plan {
    struct Result: VariableWeightResult, Storable {
        let title: String   // "2 sets @ 60s"
        let date: Date
        var secs: Int
        var weight: Double
        
        var primary: Bool {get {return true}}
        var missed: Bool {get {return false}}
        
        init(title: String, secs: Int, weight: Double) {
            self.title = title
            self.date = Date()
            self.secs = secs
            self.weight = weight
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.date = store.getDate("date")
            self.secs = store.getInt("secs")
            self.weight = store.getDbl("weight")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addDate("date", date)
            store.addInt("secs", secs)
            store.addDbl("weight", weight)
        }
    }
    
    init(_ name: String, numSets: Int, targetTime: Int?) {
        os_log("init TimedPlan for %@", type: .info, name)
        self.name = name
        self.typeName = "TimedPlan"
        self.numSets = numSets
        self.targetTime = targetTime
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? TimedPlan {
            return typeName == savedPlan.typeName &&
                name == savedPlan.name &&
                numSets == savedPlan.numSets &&
                targetTime == savedPlan.targetTime
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.typeName = "TimedPlan"
        self.numSets = store.getInt("numSets")

        let time = store.getInt("targetTime")
        if time != 0 {
            self.targetTime = time
        } else {
            self.targetTime = nil
        }
        
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.setIndex = store.getInt("setIndex")
    }
    
    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addInt("numSets", numSets)
        store.addInt("targetTime", targetTime ?? 0)
        
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addInt("setIndex", setIndex)
    }
    
    // Plan methods
    public let name: String
    public let typeName: String
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: TimedPlan = store.getObj("self")
        return result
    }
    
    public func start(_ exerciseName: String) -> StartResult {
        os_log("starting TimedPlan for %@ and %@", type: .info, name, exerciseName)
        self.setIndex = 1
        self.exerciseName = exerciseName
        
        return .ok
    }
    
    public func refresh() {
        // nothing to do
    }
    
    public func isStarted() -> Bool {
        return setIndex > 0 && !finished()
    }
    
    public func underway() -> Bool {
        return isStarted() && setIndex > 1
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        switch findTimedSetting(exerciseName) {
        case .right(let setting):
            return "\(numSets)% sets @ \(secsToStr(setting.durationSecs))"
        case .left(let err):
            return err
        }
    }
    
    public func prevLabel() -> String {
        if let result = history.last {
            return "Previous was \(secsToStr(result.secs))"
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        let labels = history.map {secsToStr($0.secs)}
        return makeHistoryFromLabels(labels)
    }
    
    public func current() -> Activity {
        frontend.assert(!finished(), "TimedPlan is finished in current")
        
        switch findTimedSetting(exerciseName) {
        case .right(let setting):
            return Activity(
                title: "Set \(setIndex)",
                subtitle: "",
                amount: "",
                details: "",
                secs: setting.durationSecs)

        case .left(let err):
            return Activity(
                title: "Set \(setIndex)",
                subtitle: err,
                amount: "",
                details: "",
                secs: 0)
        }
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: !finished(), secs: secs)
        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func completions() -> [Completion] {
        if setIndex+1 < numSets {
            return [Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})]
        } else {
            return [Completion(title: "",  isDefault: true,  callback: {() -> Void in self.doFinish()})]
        }
    }
    
    public func atStart() -> Bool {
        return setIndex == 1
    }
    
    public func finished() -> Bool {
        return setIndex > numSets
    }
    
    public func reset() {
        setIndex = 1
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Do one or more sets for a period of time with an optional weight."
    }
    
    public func findLastWeight() -> Double? {
        return history.last?.weight
    }
    
    // Internal items
    private func doNext() {
        setIndex += 1
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish() {
        setIndex += 1
        frontend.assert(finished(), "TimedPlan is not finished in doFinish")
        
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed = Date()
        }
        
        addResult()
        frontend.saveExercise(exerciseName)
    }
    
    private func addResult() {
        switch findTimedSetting(exerciseName) {
        case .right(let setting):
            let title = "\(numSets)% sets @ \(secsToStr(setting.durationSecs))"
            let result = Result(title: title, secs: setting.durationSecs, weight: setting.weight)
            history.append(result)

        case .left(_):
            break
        }
    }
    
    private let numSets: Int
    private let targetTime: Int?
    
    private var exerciseName: String = ""
    private var history: [Result] = []
    private var setIndex: Int = 0
}
