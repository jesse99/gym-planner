/// Types representing a routine within a workout.
import Foundation
import os.log

public class Exercise: Storable {
    init(_ name: String, _ formalName: String, _ plan: Plan, _ settings: Settings, hidden: Bool = false) {
        self.name = name
        self.formalName = formalName
        self.plan = plan
        self.settings = settings
        self.completed = [:]
        self.hidden = hidden
    }
    
    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.formalName = store.getStr("formalName")
        self.settings = store.getObj("settings")
        self.hidden = store.getBool("hidden")
        
        self.completed = [:]
        if store.hasKey("completed-names") {
            let names = store.getStrArray("completed-names")
            let dates = store.getDateArray("completed-dates")
            
            for (i, name) in names.enumerated() {
                self.completed[name] = dates[i]
            }
        }
        
        let pname = store.getStr("plan-type")
        switch pname {
        case "LinearPlan":            let p: LinearPlan = store.getObj("plan"); self.plan = p
        case "MastersBasicCyclePlan": let p: MastersBasicCyclePlan = store.getObj("plan"); self.plan = p
        case "NRepMaxPlan":           let p: NRepMaxPlan = store.getObj("plan"); self.plan = p
        case "PercentOfPlan":         let p: PercentOfPlan = store.getObj("plan"); self.plan = p
        case "VariableSetsPlan":      let p: VariableSetsPlan = store.getObj("plan"); self.plan = p
        case "TimedPlan":             let p: TimedPlan = store.getObj("plan"); self.plan = p
        case "FixedSetsPlan":         let p: FixedSetsPlan = store.getObj("plan"); self.plan = p
        default: frontend.assert(false, "loading exercise \(name) had unknown plan: \(pname)"); abort()
        }
    }
    
    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addStr("formalName", formalName)
        store.addStr("plan-type", plan.typeName)
        store.addObj("plan", plan)
        store.addObj("settings", settings)
        store.addBool("hidden", hidden)
        
        store.addStrArray("completed-names", Array(completed.keys))
        store.addDateArray("completed-dates", Array(completed.values))
    }
    
    /// This is used for plans that have to run a different plan first, e.g. NRepMaxPlan.
    public func withPlan(_ newName: String, _ newPlan: Plan) -> Exercise {
        return Exercise(newName, formalName, newPlan, settings, hidden: true)
    }
    
    public func sync(_ savedExercise: Exercise) {
        if plan.shouldSync(savedExercise.plan) {
            plan = savedExercise.plan
            completed = savedExercise.completed
            settings = savedExercise.settings
        } else {
            os_log("ignoring saved exercise %@", type: .info, name)
        }
    }

    public var name: String             // "Heavy Bench"
    public var formalName: String       // "Bench Press"
    public var plan: Plan
    public var settings: Settings
    
    /// Date the exercise was last completed keyed by workout name (exercises can be shared across workouts).
    public var completed: [String: Date]
    
    /// If true don't display the plan in UI.
    public var hidden: Bool
}

internal func repsStr(_ reps: Int) -> String {
    if reps == 1 {
        return "1 rep"
    } else {
        return "\(reps) reps"
    }
}
