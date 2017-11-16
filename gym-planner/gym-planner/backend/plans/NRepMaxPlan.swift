/// Used to find an N-rep max.
import Foundation
import os.log

private class NRepMaxPlan : Plan {
    // TODO: note that the master plan has to persist setting when this finishes so that it is saved under the right name
    init(_ exercise: Exercise, _ setting: VariableWeightSetting, numReps: Int) {
        os_log("entering NRepMaxPlan for %@", type: .info, exercise.name)
        
        self.exercise = exercise
        self.setting = setting
        self.numReps = numReps
        
        weight = 0.0
        setNum = 1
    }
    
    // Plan methods
    func label() -> String {
        return exercise.name
    }
    
    func sublabel() -> String {
        return "Finding \(numReps) max"
    }
    
    func prevLabel() -> String {
        return ""
    }
    
    func historyLabel() -> String {
        return ""
    }
    
    func current(n: Int) -> Activity {
        assert(!finished())
        
        let info = Weight(weight, setting.apparatus).find(.closest)
        return Activity(
            title: "Set \(setNum)",
            subtitle: "",
            amount: "\(numReps) reps @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }
    
    func restSecs() -> Int {
        return 0                // no telling how hard the current set is for the user so if he wants rest he'll have to press the start timer button
    }
    
    func completions() -> [Completion] {
        var result: [Completion] = []
        
        result.append(Completion(title: "Done", isDefault: false, callback: {self.done = true}))
        
        var prevWeight = weight
        for _ in 0..<6 {
            let nextWeight = Weight(prevWeight, setting.apparatus).nextWeight()
            result.append(Completion(title: "Add \(Weight.friendlyStr(nextWeight - weight))", isDefault: false, callback: {self.weight = nextWeight}))
            prevWeight = nextWeight
        }
        
        return result
    }
    
    func finished() -> Bool {
        return done
    }
    
    func reset() {
        weight = 0.0
        setNum = 1
        done = false
    }
    
    func description() -> String {
        return "Used to find an N\(numReps) rep max."
    }
    
    // Internal items
    private func doFinish(_ missed: Bool) {
        setting.changeWeight(weight)
        done = true
    }
    
    private let exercise: Exercise
    private let setting: VariableWeightSetting
    private let numReps: Int

    private var weight: Double
    private var setNum: Int
    private var done = false
}


