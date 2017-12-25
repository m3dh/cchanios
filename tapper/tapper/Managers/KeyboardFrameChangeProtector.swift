import UIKit

class KeyboardFrameChangeProtector {
    let globalView: UIView
    let protectView: UIView
    let animationDuration: Double = 0.5

    let protectViewMaxY: CGFloat
    let animateConstraintOriginVal: CGFloat
    let animateConstraint: NSLayoutConstraint

    init(protectView: UIView, globalView: UIView, animateConstraint: NSLayoutConstraint) {
        self.globalView = globalView
        self.protectView = protectView
        self.animateConstraintOriginVal = animateConstraint.constant
        self.animateConstraint = animateConstraint
        self.protectViewMaxY = protectView.superview!.convert(protectView.frame, to: globalView).maxY
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardMinY = keyboardFrame.cgRectValue.minY
            if keyboardMinY <= self.protectViewMaxY {
                let alreadyMoved = self.animateConstraintOriginVal - animateConstraint.constant
                let moveUpDistance = self.protectViewMaxY - keyboardMinY - alreadyMoved
                self.animateConstraint.constant -= moveUpDistance
                UIView.animate(withDuration: animationDuration, animations: { self.globalView.layoutIfNeeded() })
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let alreadyMoved = self.animateConstraintOriginVal - animateConstraint.constant
        self.animateConstraint.constant += alreadyMoved
        UIView.animate(withDuration: animationDuration, animations: {
            self.globalView.layoutIfNeeded()
        })
    }
}
