/// Used to find an N-rep max.
import Foundation
import os.log

public class NRepMaxPlan : Plan {
    // TODO: note that the master plan has to persist setting when this finishes so that it is saved under the right name
    // (or maybe this should take the setting key).
    
    // This is a bit of a weird plan because it uses a different plan's setting.
    init(_ name: String, workReps: Int, _ setting: VariableWeightSetting) {
        self.name = name
        self.numReps = workReps
        self.setting = setting
    }
    
    // Plan methods
    public let name: String
    
    public func startup(_ program: Program, _ exercise: Exercise, _ persist: Persistence) -> StartupResult {
        os_log("entering NRepMaxPlan for %@", type: .info, exercise.name)

        self.exercise = exercise
        self.weight = Weight(0.0, setting.apparatus).find(.closest).weight
        self.setNum = 1
        self.done = false

        return .ok
    }
    
    public func label() -> String {
        return exercise.name
    }
    
    public func sublabel() -> String {
        return "Finding \(numReps) rep max"
    }
    
    public func prevLabel() -> String {
        return ""
    }
    
    public func historyLabel() -> String {
        return ""
    }
    
    public func current() -> Activity {
        assert(!finished())
        
        let info = Weight(weight, setting.apparatus).find(.closest)
        return Activity(
            title: "Set \(setNum)",
            subtitle: "Finding \(numReps) rep max",
            amount: "\(numReps) reps @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }
    
    public func restSecs() -> RestTime {
        return RestTime(autoStart: false, secs: setting.restSecs)                // no telling how hard the current set is for the user so if he wants rest he'll have to press the start timer button
    }
    
    public func completions() -> [Completion] {
        var result: [Completion] = []
        
        result.append(Completion(title: "Done", isDefault: false, callback: {self.done = true}))
        
        var prevWeight = weight
        for _ in 0..<7 {
            let nextWeight = Weight(prevWeight, setting.apparatus).nextWeight()
            if nextWeight > weight {    // at some point we'll run out of plates so the new weight won't be larger
                result.append(Completion(title: "Add \(Weight.friendlyUnitsStr(nextWeight - weight))", isDefault: false, callback: {self.weight = nextWeight; self.setNum += 1}))
                prevWeight = nextWeight
            }
        }
        
        return result
    }
    
    public func atStart() -> Bool {
        return setNum == 1
    }
    
    public func finished() -> Bool {
        return done
    }
    
    public func reset() {
        self.weight = Weight(0.0, setting.apparatus).find(.closest).weight
        setNum = 1
        done = false
    }
    
    public func description() -> String {
        return "Used to find a \(numReps) rep max."
    }
    
    public func settings() -> Settings {
        return .variableWeight(setting)
    }
    
    // Internal items
    private let numReps: Int
    private var setting: VariableWeightSetting

    private var exercise: Exercise!

    private var weight: Double = 0.0
    private var setNum: Int = 1
    private var done = false
}


