/// Three week cycle using 5, 3, and 1 reps.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

public class FiveThreeOneBeginnerPlan : BaseCyclicPlan {
    init(_ name: String, withBar: Int) {
        let warmups = Warmups(withBar: withBar, firstPercent: 0.4, lastPercent: 0.6, reps: [5, 5, 3])
        let fives =  [Reps(count: 5, percent: 0.65), Reps(count: 5, percent: 0.75), Reps(count: 5, percent: 0.85, amrap: true), Reps(count: 5, percent: 0.65)]
        let threes = [Reps(count: 3, percent: 0.70), Reps(count: 3, percent: 0.80), Reps(count: 3, percent: 0.90, amrap: true), Reps(count: 3, percent: 0.70)]
        let ones =   [Reps(count: 5, percent: 0.75), Reps(count: 3, percent: 0.85), Reps(count: 1, percent: 0.95, amrap: true), Reps(count: 5, percent: 0.75)]
        let cycles = [Cycle(warmups, fives), Cycle(warmups, threes), Cycle(warmups, ones)]
        super.init(name, "FiveThreeOneBeginnerPlan", cycles)
    }
    
    public required init(from store: Store) {
        super.init(from: store)
    }
    
    public override func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: FiveThreeOneBeginnerPlan = store.getObj("self")
        return result
    }
    
    public override func description() -> String {
        return "Uses a three week cycle where in the first week you do 85% at 5+ reps, the second week 90% at 3+ reps, and the third 95% at 1+ reps. After the third week the working set weight is increased. After five cycles you're given the option of deloading. Progression is slower than most of the other beginner programs but it's also a program that will work for quite a bit longer than the more aggressive programs."
    }
    
    // Internal items
    internal override func getFinishingCompletions() -> Completions {
        var completions: [Completion] = []

        let index = BaseCyclicPlan.getCycle(cycles, history)
        if index == cycles.count - 1 {
            let missed = missedCycle()
            let fifthCycle = !history.isEmpty && history.count % 5*cycles.count == 0
            if missed {
                // User definitely missed a rep on an earlier cycle but it could have been a fluke so allow them
                // to add weight if they really want to.
                completions.append(Completion(title: "Deload",        isDefault: true,  callback: {() -> Void in self.doDeload(missed)}))
                completions.append(Completion(title: "Add Weight",    isDefault: false, callback: {() -> Void in self.doAdd(1, missed)}))
                completions.append(Completion(title: "Don't Change",  isDefault: false, callback: {() -> Void in self.doConstant(missed)}))

            } else if fifthCycle {
                // Users can optionally deload every 5th cycle so we'll make that the default to try and clue them in.
                completions.append(Completion(title: "Deload",        isDefault: true,  callback: {() -> Void in self.doDeload(true)}))
                completions.append(Completion(title: "Add Weight x2", isDefault: false, callback: {() -> Void in self.doAdd(2, false)}))
                completions.append(Completion(title: "Add Weight",    isDefault: false, callback: {() -> Void in self.doAdd(1, false)}))
                completions.append(Completion(title: "Don't Change",  isDefault: false, callback: {() -> Void in self.doConstant(false)}))

            } else {
                // Otherwise they may have missed the current cycle so we need to always give them the option to deload.
                completions.append(Completion(title: "Deload",        isDefault: false, callback: {() -> Void in self.doDeload(true)}))
                completions.append(Completion(title: "Add Weight x2", isDefault: false, callback: {() -> Void in self.doAdd(2, false)}))
                completions.append(Completion(title: "Add Weight",    isDefault: true,  callback: {() -> Void in self.doAdd(1, false)}))
                completions.append(Completion(title: "Don't Change",  isDefault: false, callback: {() -> Void in self.doConstant(false)}))
            }
            
        } else {
            completions.append(Completion(title: "Finished OK",  isDefault: true,  callback: {() -> Void in self.doConstant(false)}))
            completions.append(Completion(title: "Missed a rep", isDefault: false, callback: {() -> Void in self.doConstant(true)}))
        }
            
        return .normal(completions)
    }
    
    // Private items
    private func missedCycle() -> Bool {
        for result in history.reversed() {
            if result.cycleIndex == 0 {
                return result.missed
            } else if result.missed {
                return true
            }
        }
        return false
    }
    
    private func doAdd(_ multiplier: Int, _ missed: Bool) {
        doCompleted(missed)

        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let original = setting.weight
            setting.changeWeight(original)

            for _ in 0..<multiplier {
                let old = setting.weight
                let w = Weight(old, setting.apparatus)
                setting.changeWeight(w.nextWeight())
            }
            os_log("advanced from %.3f to %.3f", type: .info, original, setting.weight)
            
        case .left(_):
            break
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func doDeload(_ missed: Bool) {
        doCompleted(missed)

        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            let original = setting.weight
            setting.changeWeight(original)
            
            for _ in 0..<3 {
                let old = setting.weight
                let w = Weight(old, setting.apparatus)
                setting.changeWeight(w.prevWeight())
            }
            os_log("deload from %.3f to %.3f", type: .info, original, setting.weight)
            
        case .left(_):
            break
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func doConstant(_ missed: Bool) {
        doCompleted(missed)
        
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            // User doesn't want to change weights but a deload might have happened (and even if it didn't we want to reset the date
            // in settings so that deload by time doesn't kick in later).
            let weight = setting.weight
            setting.changeWeight(weight)
        case .left(_):
            break
        }
    }
    
    private func doCompleted(_ missed: Bool) {
        modifiedOn = Date()
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        let cycleIndex = FiveThreeOneBeginnerPlan.getCycle(cycles, history)
        addResult(cycleIndex, missed)
    }
}

