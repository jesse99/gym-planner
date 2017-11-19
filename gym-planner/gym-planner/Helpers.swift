/// Misc functions
import Foundation

// Good resource for what sort of plates are typically available is http://www.roguefitness.com/weightlifting-bars-plates/plates/metal-plates?gclid=CN7rt9bpgNACFQqPfgod-5IObw
// Also http://forum.bodybuilding.com/showthread.php?t=123528451
func defaultPlates() -> [(Int, Double)] {
    //    switch units {
    //    case .imperial:
    return [(2, 2.5), (2, 5), (2, 10), (2, 25), (4, 45)]
    
    //    case .metric:
    //        let plates = [1.25, 2.5, 5, 10, 15, 20, 25]
    //        return plates.map {$0*Double.kgToLb}
    //    }
}


