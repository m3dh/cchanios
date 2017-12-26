import UIKit

class KeyboardFrameChangeProtector {
    let globalView: UIView
    let protectView: UIView
    let animationDuration: Double = 0.2

    let animateConstraintOriginVal: CGFloat
    let animateConstraint: NSLayoutConstraint

    var previousKeyboardFrameMinY: CGFloat

    init(protectView: UIView, globalView: UIView, animateConstraint: NSLayoutConstraint) {
        self.globalView = globalView
        self.protectView = protectView
        self.animateConstraintOriginVal = animateConstraint.constant
        self.animateConstraint = animateConstraint
        self.previousKeyboardFrameMinY = globalView.frame.maxY
    }

    func protectViewSizeChanged() {
        let protectedMaxY = protectView.superview!.convert(protectView.frame, to: globalView).maxY
        if self.previousKeyboardFrameMinY != protectedMaxY {
            let moveUpDistance = protectedMaxY - self.previousKeyboardFrameMinY
            if moveUpDistance != 0 && self.animateConstraint.constant - moveUpDistance <= self.animateConstraintOriginVal {
                self.animateConstraint.constant -= moveUpDistance
                UIView.animate(withDuration: animationDuration, animations: { self.globalView.layoutIfNeeded() })
            }
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardMinY = keyboardFrame.cgRectValue.minY
            let protectedMaxY = protectView.superview!.convert(protectView.frame, to: globalView).maxY
            self.previousKeyboardFrameMinY = keyboardMinY
            if keyboardMinY != protectedMaxY {
                let moveUpDistance = protectedMaxY - keyboardMinY
                if moveUpDistance != 0 && self.animateConstraint.constant - moveUpDistance <= self.animateConstraintOriginVal {
                    self.animateConstraint.constant -= moveUpDistance
                    UIView.animate(withDuration: animationDuration, animations: { self.globalView.layoutIfNeeded() })
                }
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        self.animateConstraint.constant = self.animateConstraintOriginVal
        self.previousKeyboardFrameMinY = globalView.frame.maxY
        UIView.animate(withDuration: animationDuration, animations: {
            self.globalView.layoutIfNeeded()
        })
    }
}
