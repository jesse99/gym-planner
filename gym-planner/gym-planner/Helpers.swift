/// Misc functions
import Foundation
import UIKit

// Good resource for what sort of plates are typically available is http://www.roguefitness.com/weightlifting-bars-plates/plates/metal-plates?gclid=CN7rt9bpgNACFQqPfgod-5IObw
// Also http://forum.bodybuilding.com/showthread.php?t=123528451
func defaultPlates() -> [Double] {
    //    switch units {
    //    case .imperial:
    return [2.5, 5, 10, 25, 45]
    
    //    case .metric:
    //        let plates = [1.25, 2.5, 5, 10, 15, 20, 25]
    //        return plates.map {$0*Double.kgToLb}
    //    }
}

func defaultBumpers() -> [Double] {
//    switch units
//    {
//    case .imperial:
        return [15.0, 25, 45]
        
//    case .metric:
//        let plates = [5.0, 10, 20]
//        return plates.map {$0*Double.kgToLb}
//    }
}

func secsToStr(_ secs: Int) -> String {
    if secs <= 60 {
        return "\(secs)s"
    } else {
        return String(format: "%0.1fm", arguments: [Double(secs)/60.0])
    }
}

func strToSecs(_ inText: String) -> Int? {
    var multiplier = 1.0
    
    var text = inText.trimmingCharacters(in: CharacterSet.whitespaces)
    if text.hasSuffix("s") {
        text.remove(at: text.index(before: text.endIndex))
    } else if text.hasSuffix("m") {
        multiplier = 60.0
        text.remove(at: text.index(before: text.endIndex))
    } else if text.hasSuffix("h") {
        multiplier = 60.0*60.0
        text.remove(at: text.index(before: text.endIndex))
    }
    
    if let value = Double(text) {
        return Int(multiplier*value)
    }
    return nil
}

func grayColor(_ gray: Int, _ alpha: Float) -> UIColor {
    return UIColor(red: CGFloat(gray)/255.0, green: CGFloat(gray)/255.0, blue: CGFloat(gray)/255.0, alpha: CGFloat(alpha))
}

func newColor(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
    return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(1.0))
}

