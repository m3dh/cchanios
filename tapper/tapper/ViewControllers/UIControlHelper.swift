import UIKit

class UIControlHelper {
    static let animationDuration: Double = 0.3

    static func markTextFieldError(textfield: UITextField) {
        // mark the text field as an error with red border
        textfield.layer.borderWidth = 1.1
        textfield.layer.borderColor = UIColor.red.cgColor
    }

    static func resetTextFieldStyle(textfield: UITextField) {
        // reset to default iOS UI style
        textfield.layer.cornerRadius = 5.0;
        textfield.layer.borderWidth = 1.0
        textfield.layer.borderColor = UIColor.lightGray.cgColor
    }

    static func safelySetUILabelText(label: UILabel, labelHeight: NSLayoutConstraint, text: String) {
        label.text = text
        let size = label.sizeThatFits(label.bounds.size)
        if size.height != labelHeight.constant && size.height != label.frame.size.height{
            labelHeight.constant = size.height
            if let superview = label.superview {
                UIView.animate(withDuration: animationDuration, animations: {
                    superview.layoutIfNeeded()
                })
            }
        }
    }
}
