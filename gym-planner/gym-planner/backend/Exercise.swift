/// Types representing a routine within a workout.
import Foundation
import os.log

public class Exercise: Storable {
    init(_ name: String, _ formalName: String, _ plan: Plan, _ settings: Settings, hidden: Bool = false) {
        self.name = name
        self.formalName = formalName
        self.plan = plan
        self.nextExercise = nil
        self.prevExercise = nil
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
        
        if store.hasKey("nextExercise") {
            self.nextExercise = store.getStr("nextExercise")
        } else {
            self.nextExercise = nil
        }
        if store.hasKey("prevExercise") {
            self.prevExercise = store.getStr("prevExercise")
        } else {
            self.prevExercise = nil
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
        case "SteadyStateCardioPlan": let p: SteadyStateCardioPlan = store.getObj("plan"); self.plan = p
        case "HIITPlan":              let p: HIITPlan = store.getObj("plan"); self.plan = p
        case "VariableRepsPlan":      let p: VariableRepsPlan = store.getObj("plan"); self.plan = p
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
        
        if let next = nextExercise {
            store.addStr("nextExercise", next)
        }
        if let prev = prevExercise {
            store.addStr("prevExercise", prev)
        }
        
        store.addStrArray("completed-names", Array(completed.keys))
        store.addDateArray("completed-dates", Array(completed.values))
    }
    
    /// This is used for plans that have to run a different plan first, e.g. NRepMaxPlan.
    public func withPlan(_ newName: String, _ newPlan: Plan) -> Exercise {
        let result = Exercise(newName, formalName, newPlan, settings, hidden: true)
        result.nextExercise = self.nextExercise
        result.prevExercise = self.prevExercise
        return result
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
    
    /// These are used for exercises that support progression. For example, progressively harder planks. Users
    /// can use the Options screens to choose which version they want to perform.
    public var prevExercise: String?
    public var nextExercise: String?
    
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
