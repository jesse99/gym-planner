import UIKit

extension UIFont {
    func makeBold() -> UIFont {
        if let descriptor = self.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: self.pointSize)
        }
        return self
    }
}

