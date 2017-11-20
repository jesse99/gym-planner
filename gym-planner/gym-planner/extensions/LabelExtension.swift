import UIKit

extension UILabel {
    func setColor(_ color: UIColor) {
        if let text = self.text , !text.isEmpty {
            if var attrs = self.attributedText?.attributes(at: 0, effectiveRange: nil) {
                attrs[NSAttributedStringKey.foregroundColor] = color
                self.attributedText = NSAttributedString(string: text, attributes: attrs)
            }
        }
    }
}

