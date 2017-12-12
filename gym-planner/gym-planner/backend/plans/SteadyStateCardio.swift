/// Used for low-intensity steady state cardio (LISS).
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class SteadyStateCardioPlan : Plan {
    class Result: BaseResult {
        let mins: Int
        let calories: Int
        let intensity: String
        
        init(_ mins: Int, _ calories: Int, _ intensity: String) {
            self.mins = mins
            self.calories = calories
            self.intensity = intensity
            super.init(minsToStr(mins))
        }
        
        required init(from store: Store) {
            self.mins = store.getInt("mins")
            self.calories = store.getInt("calories")
            self.intensity = store.getStr("intensity")
            super.init(from: store)
        }
        
        override func save(_ store: Store) {
            super.save(store)
            store.addInt("mins", mins)
            store.addInt("calories", calories)
            store.addStr("intensity", intensity)
        }
    }
    
    init(_ name: String, daysPerWeek: Int, minsPerDay: Int, maxRollOverMins: Int) {
        os_log("init SteadyStateCardioPlan for %@", type: .info, name)
        self.planName = name
        self.typeName = "SteadyStateCardioPlan"
        self.daysPerWeek = daysPerWeek
        self.minsPerDay = minsPerDay
        self.maxRollOverMins = maxRollOverMins
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? SteadyStateCardioPlan {
            return typeName == savedPlan.typeName &&
                planName == savedPlan.planName &&
                daysPerWeek == savedPlan.daysPerWeek &&
                minsPerDay == savedPlan.minsPerDay &&
                maxRollOverMins == savedPlan.maxRollOverMins
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.planName = store.getStr("name")
        self.typeName = "SteadyStateCardioPlan"
        self.daysPerWeek = store.getInt("daysPerWeek")
        self.minsPerDay = store.getInt("minsPerDay")
        self.maxRollOverMins = store.getInt("maxRollOverMins")

        self.workoutName = store.getStr("workoutName", ifMissing: "unknown")
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.state = store.getObj("state", ifMissing: .waiting)
        self.modifiedOn = store.getDate("modifiedOn", ifMissing: Date.distantPast)

        switch state {
        case .waiting:
            break
        default:
            let calendar = Calendar.current
            if !calendar.isDate(modifiedOn, inSameDayAs: Date()) {
                state = .waiting
            }
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", planName)
        store.addInt("daysPerWeek", daysPerWeek)
        store.addInt("minsPerDay", minsPerDay)
        store.addInt("maxRollOverMins", maxRollOverMins)
        
        store.addStr("workoutName", workoutName)
        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
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
        let result: SteadyStateCardioPlan = store.getObj("self")
        return result
    }
    
    public func start(_ workout: Workout, _ exerciseName: String) -> Plan? {
        os_log("starting SteadyStateCardioPlan for %@ and %@", type: .info, planName, exerciseName)
        self.workoutName = workout.name
        self.exerciseName = exerciseName
        self.modifiedOn = Date.distantPast  // user hasn't really changed anything yet

        self.state = .started
        frontend.saveExercise(exerciseName)        
        return nil
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
        let results = getThisWeeksResults()
        let completed = results.reduce(0) {$0 + $1.mins}
        let goal = getGoal()
        if completed < goal {
            return minsToStr(goal - completed) + " remaining"
        } else if completed == goal {
            return "done"
        } else {
            return "over by " + minsToStr(completed - goal)
        }
    }
    
    public func prevLabel() -> String {
        return ""
    }
    
    public func historyLabel() -> String {
        let filtered = history.filter {!$0.intensity.isEmpty}
        let labels = filtered.map {$0.intensity}
        return makeHistoryFromLabels(labels)
    }
    
    public func current() -> Activity {
        let results = getThisWeeksResults()
        let completed = results.reduce(0) {$0 + $1.mins}
        let goal = getGoal()

        var title = ""
        if completed < goal {
            title = minsToStr(goal - completed) + " remaining"
        } else {
            title = "0 mins remaining"
        }

        return Activity(
            title: title,
            subtitle: "",
            amount: "",
            details: "",
            buttonName: "Done",
            showStartButton: true,
            color: nil)
    }
    
    public func restSecs() -> RestTime {
        return RestTime(autoStart: false, secs: 0)
    }
    
    public func restSound() -> UInt32 {
        return UInt32(kSystemSoundID_Vibrate)
    }
    
    public func completions() -> Completions {
        return .cardio(self.doFinish)
    }
    
    public func reset() {
        modifiedOn = Date()
        state = .started
        refresh()   // we do this to ensure that users always have a way to reset state to account for changes elsewhere
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "Used for low intensity steady state cardio, e.g. a treadmill, an exercise bike, etc."
    }
    
    public func currentWeight() -> Double? {
        return nil
    }
    
    // Internal items
    private func doFinish(_ mins: Int, _ calories: Int) {
        modifiedOn = Date()
        state = .finished
        
        if mins > 0 {
            let results = getThisWeeksResults()
            let completed = results.reduce(0) {$0 + $1.mins}
            let goal = getGoal()
            if completed < goal && completed+mins >= goal {
                if case let .right(exercise) = findExercise(exerciseName) {
                    exercise.completed[workoutName] = Date()
                }
            }
            
            if case let .right(setting) = findIntensitySetting(exerciseName) {
                let result = Result(mins, calories, setting.intensity)
                history.append(result)
            }
        }
        
        frontend.saveExercise(exerciseName)
    }
    
    private func getGoal() -> Int {
        let target = minsPerDay*daysPerWeek
        let results = getLastWeeksResults()
        let completed = results.reduce(0) {$0 + $1.mins}

        var goal = target
        if completed > 0 && completed < target {
            goal += min(target - completed, maxRollOverMins)
        }
        
        return goal
    }
    
    private func getThisWeeksResults() -> [Result] {
        return getWeeklyResults(forDate: Date())
    }
    
    private func getLastWeeksResults() -> [Result] {
        let calendar = Calendar.current
        if let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) {
            return getWeeklyResults(forDate: lastWeek)
        } else {
            return []
        }
    }
    
    private func getWeeklyResults(forDate: Date) -> [Result] {
        var results: [Result] = []
        
        let calendar = Calendar.current
        for result in history.reversed() {
            if calendar.isDate(result.date, equalTo: forDate, toGranularity: .weekOfYear) {
                results.append(result)
            }
        }
        
        return results
    }

    private let daysPerWeek: Int
    private let minsPerDay: Int
    private let maxRollOverMins: Int
    
    private var modifiedOn = Date.distantPast
    private var workoutName: String = ""
    private var exerciseName: String = ""
    private var history: [Result] = []
}
