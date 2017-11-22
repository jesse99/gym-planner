/// Misc functions
import Foundation
import UIKit

// Good resource for what sort of plates are typically available is http://www.roguefitness.com/weightlifting-bars-plates/plates/metal-plates?gclid=CN7rt9bpgNACFQqPfgod-5IObw
// Also http://forum.bodybuilding.com/showthread.php?t=123528451
func defaultPlates() -> [(Int, Double)] {
    //    switch units {
    //    case .imperial:
    return [(4, 2.5), (4, 5), (4, 10), (4, 25), (8, 45)]
    
    //    case .metric:
    //        let plates = [1.25, 2.5, 5, 10, 15, 20, 25]
    //        return plates.map {$0*Double.kgToLb}
    //    }
}

func defaultBumpers() -> [(Int, Double)] {
//    switch units
//    {
//    case .imperial:
        return [(4, 10.0), (4, 25), (8, 45)]
        
//    case .metric:
//        let plates = [5.0, 10, 20]
//        return plates.map {$0*Double.kgToLb}
//    }
}

func grayColor(_ gray: Int, _ alpha: Float) -> UIColor {
    return UIColor(red: CGFloat(gray)/255.0, green: CGFloat(gray)/255.0, blue: CGFloat(gray)/255.0, alpha: CGFloat(alpha))
}

func newColor(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
    return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(1.0))
}

