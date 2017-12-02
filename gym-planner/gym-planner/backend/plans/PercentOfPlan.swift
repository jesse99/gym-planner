/// Plan that uses a percent of the weight from another plan.
import Foundation
import os.log

public class PercentOfPlan : Plan {
    struct Set: Storable {
        let title: String      // "Workset 3 of 4"
        let subtitle: String   // "90% of 140 lbs"
        let numReps: Int
        let weight: Weight.Info
        let warmup: Bool
        
        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, percent: Double, weight: Double) {
            self.title = "Warmup \(phase) of \(phaseCount)"
            self.weight = Weight(percent*weight, apparatus).closest(below: weight)
            self.numReps = numReps
            self.warmup = true

            let info = Weight(weight, apparatus).closest()
            let p = String(format: "%.0f", 100.0*percent)
            self.subtitle = "\(p)% of \(info.text)"
        }

        init(_ apparatus: Apparatus, phase: Int, phaseCount: Int, numReps: Int, weight: Double) {
            self.title = "Workset \(phase) of \(phaseCount)"
            self.subtitle = ""
            self.weight = Weight(weight, apparatus).closest()
            self.numReps = numReps
            self.warmup = false
        }

        init(from store: Store) {
            self.title = store.getStr("title")
            self.subtitle = store.getStr("subtitle")
            self.numReps = store.getInt("numReps")
            self.weight = store.getObj("weight")
            self.warmup = store.getBool("warmup")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addStr("subtitle", subtitle)
            store.addInt("numReps", numReps)
            store.addObj("weight", weight)
            store.addBool("warmup", warmup)
        }
    }
    
    struct Result: DerivedWeightResult, Storable {
        let title: String   // "135 lbs 3x5"
        let date: Date
        var weight: Double

        init(title: String, weight: Double) {
            self.title = title
            self.date = Date()
            self.weight = weight
        }
        
        init(from store: Store) {
            self.title = store.getStr("title")
            self.date = store.getDate("date")
            self.weight = store.getDbl("weight")
        }
        
        func save(_ store: Store) {
            store.addStr("title", title)
            store.addDate("date", date)
            store.addDbl("weight", weight)
        }
    }
    
    init(_ name: String, _ otherName: String, firstWarmup: Double, warmupReps: [Int], workSets: Int, workReps: Int, percent: Double) {
        os_log("init PercentOfPlan for %@", type: .info, name)
        self.name = name
        self.typeName = "PercentOfPlan"
        self.otherName = otherName
        self.firstWarmup = firstWarmup
        self.warmupReps = warmupReps
        self.workSets = workSets
        self.workReps = workReps
        self.percent = percent
    }
    
    // This should consider typeName and whatever was passed into the init above.
    public func shouldSync(_ inPlan: Plan) -> Bool {
        if let savedPlan = inPlan as? PercentOfPlan {
            return typeName == savedPlan.typeName &&
                name == savedPlan.name &&
                otherName == savedPlan.otherName &&
                firstWarmup == savedPlan.firstWarmup &&
                warmupReps == savedPlan.warmupReps &&
                workSets == savedPlan.workSets &&
                workReps == savedPlan.workReps &&
                percent == savedPlan.percent
        } else {
            return false
        }
    }
    
    public required init(from store: Store) {
        self.name = store.getStr("name")
        self.typeName = "PercentOfPlan"
        self.otherName = store.getStr("otherName")
        self.firstWarmup = store.getDbl("firstWarmup")
        self.warmupReps = store.getIntArray("warmupReps")
        self.workSets = store.getInt("workSets")
        self.workReps = store.getInt("workReps")
        self.percent = store.getDbl("percent")
        
        self.exerciseName = store.getStr("exerciseName")
        self.history = store.getObjArray("history")
        self.sets = store.getObjArray("sets")
        self.setIndex = store.getInt("setIndex")
    }
    
    public func save(_ store: Store) {
        store.addStr("name", name)
        store.addStr("otherName", otherName)
        store.addDbl("firstWarmup", firstWarmup)
        store.addIntArray("warmupReps", warmupReps)
        store.addInt("workSets", workSets)
        store.addInt("workReps", workReps)
        store.addDbl("percent", percent)

        store.addStr("exerciseName", exerciseName)
        store.addObjArray("history", history)
        store.addObjArray("sets", sets)
        store.addInt("setIndex", setIndex)
    }
    
    // Plan methods
    public let name: String
    public let typeName: String
    
    public func clone() -> Plan {
        let store = Store()
        store.addObj("self", self)
        let result: PercentOfPlan = store.getObj("self")
        return result
    }
    
    public func start(_ exerciseName: String) -> StartResult {
        os_log("starting PercentOfPlan for %@ and %@", type: .info, name, exerciseName)

        self.sets = []
        self.setIndex = 0
        self.exerciseName = exerciseName

        switch findApparatus(exerciseName) {
        case .right(let apparatus):
            switch getOtherWeight() {
            case .right(let otherWeight):
                let workingSetWeight = percent*otherWeight;
                os_log("workingSetWeight = %.3f", type: .info, workingSetWeight)
                
                var warmupsWithBar = 0
                switch apparatus {
                case .barbell(bar: _, collar: _, plates: _, bumpers: _, magnets: _, warmupsWithBar: let n): warmupsWithBar = n
                default: break
                }
                
                let numWarmups = warmupsWithBar + warmupReps.count
                for i in 0..<warmupsWithBar {
                    sets.append(Set(apparatus, phase: i+1, phaseCount: numWarmups, numReps: warmupReps.first ?? 5, percent: 0.0, weight: workingSetWeight))
                }
                
                let delta = warmupReps.count > 0 ? (0.9 - firstWarmup)/Double(warmupReps.count - 1) : 0.0
                for (i, reps) in warmupReps.enumerated() {
                    let percent = firstWarmup + Double(i)*delta
                    sets.append(Set(apparatus, phase: warmupsWithBar + i + 1, phaseCount: numWarmups, numReps: reps, percent: percent, weight: workingSetWeight))
                }
                
                for i in 0..<workSets {
                    sets.append(Set(apparatus, phase: i+1, phaseCount: workSets, numReps: workReps, weight: workingSetWeight))
                }
                frontend.saveExercise(exerciseName)

            case .left(let message):
                return .error(message)
            }
            
            return .ok
            
        case .left(let err):
            return .error(err)
        }
    }
    
    public func isStarted() -> Bool {
        return !sets.isEmpty && !finished()
    }
    
    public func label() -> String {
        return exerciseName
    }
    
    public func sublabel() -> String {
        var suffix = ""
        switch getOtherWeight() {
        case .right(let otherWeight):
            suffix = "'s \(Weight.friendlyUnitsStr(otherWeight, plural: true))"
        case .left(_):
            break
        }

        if let weight = sets.last?.weight {
            let p = Int(100.0*self.percent)
            return "\(weight.text) (\(p)% of \(otherName)\(suffix))"

        } else {
            let p = Int(100.0*self.percent)
            return "\(p)% of \(otherName)\(suffix)"
        }
    }
    
    public func prevLabel() -> String {
        if let result = history.last {
            return "Previous was \(Weight.friendlyUnitsStr(result.weight))"
        } else {
            return ""
        }
    }
    
    public func historyLabel() -> String {
        let weights = history.map {$0.weight}
        return makeHistoryLabel(Array(weights))
    }
    
    public func current() -> Activity {
        frontend.assert(!finished(), "PercentOfPlan finished in current")
        
        let info = sets[setIndex].weight
        return Activity(
            title: sets[setIndex].title,
            subtitle: sets[setIndex].subtitle,
            amount: "\(repsStr(sets[setIndex].numReps)) @ \(info.text)",
            details: info.plates,
            secs: nil)               // this is used for timed exercises
    }
    
    public func restSecs() -> RestTime {
        switch findRestSecs(exerciseName) {
        case .right(let secs):
            return RestTime(autoStart: !finished() && !sets[setIndex].warmup, secs: secs)

        case .left(_):
            return RestTime(autoStart: false, secs: 0)
        }
    }
    
    public func completions() -> [Completion] {
        if setIndex+1 < sets.count {
            return [Completion(title: "", isDefault: true, callback: {() -> Void in self.doNext()})]
        } else {
            return [
                Completion(title: "Done", isDefault: false, callback: {() -> Void in self.doFinish()})]
        }
    }
    
    public func atStart() -> Bool {
        return setIndex == 0
    }
    
    public func finished() -> Bool {
        return setIndex == sets.count
    }
    
    public func reset() {
        setIndex = 0
        frontend.saveExercise(exerciseName)
    }
    
    public func description() -> String {
        return "This does an exercise at a percentage of another exercises workset. It's typically used to perform a light or medium version of an exercise."
    }
    
    // Internal items
    private func doNext() {
        setIndex += 1
        frontend.saveExercise(exerciseName)
    }
    
    private func doFinish() {
        if case let .right(exercise) = findExercise(exerciseName) {
            exercise.completed = Date()
        }
        
        setIndex += 1
        frontend.assert(finished(), "PercentOfPlan not finished in doFinish")
        addResult()
        frontend.saveExercise(exerciseName)
    }
    
    private func addResult() {
        let numWorkSets = sets.reduce(0) {(sum, set) -> Int in sum + (set.warmup ? 0 : 1)}
        let title = "\(sets.last!.weight.text) \(numWorkSets)x\(sets.last!.numReps)"
        let result = Result(title: title, weight: sets.last!.weight.weight)
        history.append(result)
    }
    
    private func getOtherWeight() -> Either<String, Double> {
        switch findExercise(otherName) {
        case .right(let exercise):
            if case .ok = exercise.plan.clone().start(otherName) {
                switch exercise.settings {
                case .variableWeight(let setting): return .right(setting.weight)
                case .fixedWeight(let setting): return .right(setting.weight)
                default: return .left("\(otherName) doesn't use a variable or fixed weight plan")
                }
            } else {
                return .left("Execute \(otherName) first")
            }
        case .left(let err):
            return .left(err)
        }
    }
    
    private let otherName: String
    private let firstWarmup: Double
    private let warmupReps: [Int]
    private let workSets: Int;
    private let workReps: Int
    private let percent: Double

    private var exerciseName: String = ""
    private var history: [Result] = []
    private var sets: [Set] = []
    private var setIndex: Int = 0
}


