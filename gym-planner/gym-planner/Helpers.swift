/// Misc functions
import Foundation
import UIKit

// Good resource for what sort of plates are typically available is http://www.roguefitness.com/weightlifting-bars-plates/plates/metal-plates?gclid=CN7rt9bpgNACFQqPfgod-5IObw
// Also http://forum.bodybuilding.com/showthread.php?t=123528451
func availablePlates() -> [Double] {
//    let app = UIApplication.shared.delegate as! AppDelegate
//    switch app.units() {
//    case .imperial:
        return [0.25, 0.5, 1.0, 1.25, 2.5, 5, 10, 15, 25, 35, 45, 55, 100, 125, 140, 150, 175, 200]
        
//    case .metric:
//        let plates = [0.25, 0.5, 1.0, 1.25, 2.5, 5, 10, 15, 20, 25, 50, 75, 100]
//        return plates.map {$0*Double.kgToLb}
//    }
}


func defaultPlates() -> [Double] {
    //    switch units {
    //    case .imperial:
    return [2.5, 5, 10, 25, 45]
    
    //    case .metric:
    //        let plates = [1.25, 2.5, 5, 10, 15, 20, 25]
    //        return plates.map {$0*Double.kgToLb}
    //    }
}

func availableBumpers() -> [Double] {
//    let app = UIApplication.shared.delegate as! AppDelegate
//    switch app.units() {
//    case .imperial:
        return [10.0, 15, 25, 35, 45, 55, 100]
        
//    case .metric:
//        let plates = [5.0, 10, 15, 20, 25, 50]
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

func defaultDumbbells() -> [Double] {
//    switch units {
//    case .imperial:
        return [
            5.0, 10, 15, 20, 25,
            30, 35, 40, 45, 50, 55,
            60, 70, 80, 90,
            100, 110, 120, 130, 140, 150]
        
//    case .metric:
//        let plates = [1.0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 22,
//                      24, 26, 28, 30, 32, 34, 36, 38, 40,
//                      45, 50, 55, 60, 70]
//        return plates.map {$0*Double.kgToLb}
//    }
}

func availableMagnets() -> [Double] {
//    let app = UIApplication.shared.delegate as! AppDelegate
//    switch app.units() {
//    case .imperial:
        return [0.25, 0.5, 0.625, 0.75, 1.0, 1.25, 2.0, 2.5]
        
//    case .metric:
//        let plates = [0.25, 0.5, 0.75, 1.0]
//        return plates.map {$0*Double.kgToLb}
//    }
}

func defaultMachine() -> MachineRange
{
    //    switch units
    //    {
    //    case .imperial:
    return MachineRange(min: 10, max: 200, step: 10)
    
    //    case .metric:
    //        return (5.0, 5.0, 100.0)
    //    }
}

func zeroMachine() -> MachineRange
{
    return MachineRange(min: 0, max: 0, step: 0)
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

