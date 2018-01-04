import UIKit

class UIControlHelper {
    static let animationDuration: Double = 0.3

    static func markTextFieldError(textfield: UITextField) {
        if let underlineTextfield = textfield as? UnderlineTextField {
            underlineTextfield.tintColor = UIColor.red
        } else {
            // mark the text field as an error with red border
            textfield.layer.borderWidth = 1.1
            textfield.layer.borderColor = UIColor.red.cgColor
        }
    }

    static func resetTextFieldStyle(textfield: UITextField) {
        if let underlineTextfield = textfield as? UnderlineTextField {
            underlineTextfield.tintColor = ColorCollection.TextfieldDefaultTintColor
        } else {
            // reset to default iOS UI style
            textfield.layer.cornerRadius = 5.0;
            textfield.layer.borderWidth = 1.0
            textfield.layer.borderColor = UIColor.lightGray.cgColor
        }
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

    static func findAndHideShadowView(under view: UIView, hide: Bool) {
        if view is UIImageView && view.bounds.size.height <= 1 {
            (view as! UIImageView).isHidden = hide
        } else {
            for subView in view.subviews {
                findAndHideShadowView(under: subView, hide: hide)
            }
        }
    }
}
