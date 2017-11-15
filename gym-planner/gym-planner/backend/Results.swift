// Used to show a list or chart of what happened with a particular exercise.
import Foundation

protocol VariableWeightResult {
    var date: Date {get}
    var title: String {get}
    
    // This is set for the exercise that really matters, e.g. the one where weight progresses.
    var primary: Bool {get}
    
    var warmupWeight: Double {get}  // some plans want to use the max warmup weight from a different exercise
    
    var weight: Double {get set}    // TODO: should this be inside an enum? (so we can have one result type)
    var missed: Bool {get set}      // TODO: should we use an enum here?
}

