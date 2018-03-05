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

    static func delayAndDo(delay: Double, task: @escaping ()->Void) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: task)
    }

    static func startAsyncTaskAndBlockCurrentWindow(window: UIViewController, task: @escaping (@escaping(Bool)->Void)->Void, message: String, completion: @escaping ()->Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor.black

        // Present a blocker view
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.startAnimating();
        alertController.view.addSubview(activityIndicator)
        window.present(alertController, animated: true, completion: nil)

        // Create the completion task
        let completion = {(succeeded: Bool)->Void in
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            alertController.dismiss(animated: true, completion: {()->Void in
                if succeeded {
                    completion()
                }
            })
        }

        // Start the real task
        task(completion)
    }

    static func removeTypePartFromId(id: String) -> String {
        let possibleSpliter = id.index(of: ":")
        if let spliter = possibleSpliter {
            return String(id[id.index(after: spliter)...])
        }
        else {
            return id
        }
    }
}
