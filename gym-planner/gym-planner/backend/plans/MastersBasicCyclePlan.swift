/// N (typically three) week cycle where reps drop and weight goes up. Progression happens after the
/// last cycle if the first cycle went OK.
import AVFoundation // for kSystemSoundID_Vibrate
import Foundation
import os.log

// TODO: Might want a version of this for younger people: less warmup sets, no rest on last warmup, less deload by time, less weight on medium/light days
public class MastersBasicCyclePlan : BaseCyclicPlan {
    init(_ name: String, _ cycles: [Cycle]) {
        super.init(name, "MastersBasicCyclePlan", cycles, deloads: [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.9, 0.85, 0.8])
    }
    
    public required init(from store: Store) {
        super.init(from: store)
    }
    
    public override func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: MastersBasicCyclePlan = store.getObj("self")
        return result
    }
    
    // Note that this is called after advancing.
    public override func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            if case .finished = state {
                return RestTime(autoStart: true, secs: secs)   // TODO: make this an option?
            } else if setIndex > 0 && sets[setIndex-1].warmup && !sets[setIndex].warmup {
                return RestTime(autoStart: true, secs: secs/2)
            } else if !sets[setIndex].warmup {
                return RestTime(autoStart: true, secs: secs)
            } else {
                return RestTime(autoStart: false, secs: secs)
            }

        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }

    public override func description() -> String {
        return "This is designed for lifters in their 40s and 50s. Typically it's used with three week cycles where the first week is sets of five, the second week sets of three, and the third week sets of one with the second week using 5% more weight and the third week 10% more weight. If all reps were completed for the sets of five then the weight is increased after the third week."
    }
    
    // Internal items
    internal override func adjustUnitWeight() -> Double? {
        // doAdvance handles the case where the first cycle was missed (we just don't advance).
        // Here we handle the other cases where we ask the user to repeat what he did last time.
        let index = BaseCyclicPlan.getCycle(cycles, history)
        if index > 0 {
            if let result = BaseCyclicPlan.findCycleResult(history, index), result.missed {
                let scale = 1.0/cycles[index].maxPercent()  // mapping from maxWeight to unitWeight
                return scale*result.getWeight()
            }
        }
        return nil
    }
    
    internal override func getFinishingCompletions() -> Completions {
        return .normal([
            Completion(title: "Finished OK",  isDefault: true,  callback: {() -> Void in self.doFinish(false)}),
            Completion(title: "Missed a rep", isDefault: false, callback: {() -> Void in self.doFinish(true)})])
    }
    
    // Private items
    private func doFinish(_ missed: Bool) {
        modifiedOn = Date()
        state = .finished
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed[workoutName] = Date()
        }
        
        let cycleIndex = MastersBasicCyclePlan.getCycle(cycles, history)
        addResult(cycleIndex, missed)
        
        if cycleIndex == cycles.count-1 {
            doAdvance()
        } else {
            doConstant()
        }
        frontend.saveExercise(exerciseName)
    }
    
    private func doAdvance() {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            if let result = BaseCyclicPlan.findCycleResult(history, 0) {
                if !result.missed {
                    let old = setting.weight
                    let w = Weight(old, setting.apparatus)
                    setting.changeWeight(w.nextWeight())
                    setting.stalls = 0
                    os_log("advanced from %.3f to %.3f", type: .info, old, setting.weight)
                    
                } else {
                    setting.sameWeight()
                    setting.stalls += 1
                    os_log("stalled = %d", type: .info, setting.stalls)
                }
            }
            
        case .left(_):
            break
        }
    }
    
    private func doConstant() {
        switch findVariableWeightSetting(exerciseName) {
        case .right(let setting):
            // We're on a cycle where the weights don't advance but we still need to indicate that
            // we've done a lift so that deload by time doesn't kick in.
            setting.sameWeight()
        case .left(_):
            break
        }
    }
}
