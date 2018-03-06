import UIKit

class KeyboardFrameChangeProtector {
    let globalView: UIView
    let protectView: UIView
    let animationDuration: Double = 0.2

    let navigationBarHeight: CGFloat
    let animateConstraintOriginVal: CGFloat
    let animateConstraint: NSLayoutConstraint

    var previousKeyboardFrameMinY: CGFloat

    init(protectView: UIView, globalView: UIView, animateConstraint: NSLayoutConstraint) {
        self.globalView = globalView
        self.protectView = protectView
        self.animateConstraintOriginVal = animateConstraint.constant
        self.animateConstraint = animateConstraint
        self.previousKeyboardFrameMinY = globalView.frame.maxY
        self.navigationBarHeight = globalView.frame.maxY - globalView.frame.height
    }

    func protectViewSizeChanged() {
        let protectedMaxY = protectView.superview!.convert(protectView.frame, to: globalView).maxY + self.navigationBarHeight
        if self.previousKeyboardFrameMinY != protectedMaxY {
            let moveUpDistance = protectedMaxY - self.previousKeyboardFrameMinY
            if moveUpDistance != 0 {
                if self.animateConstraint.constant - moveUpDistance <= self.animateConstraintOriginVal {
                    self.animateConstraint.constant -= moveUpDistance
                    UIView.animate(withDuration: animationDuration, animations: { self.globalView.layoutIfNeeded() })
                } else {
                    self.animateConstraint.constant = self.animateConstraintOriginVal
                    UIView.animate(withDuration: animationDuration, animations: { self.globalView.layoutIfNeeded() })
                }
            }
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardMinY = keyboardFrame.cgRectValue.minY
            let protectedMaxY = protectView.superview!.convert(protectView.frame, to: globalView).maxY + self.navigationBarHeight
            self.previousKeyboardFrameMinY = keyboardMinY
            print("keyboardMinY \(keyboardMinY), protectedMaxY \(protectedMaxY)")
            if keyboardMinY != protectedMaxY {
                let moveUpDistance = protectedMaxY - keyboardMinY
                if moveUpDistance != 0 {
                    if self.animateConstraint.constant - moveUpDistance <= self.animateConstraintOriginVal {
                        self.animateConstraint.constant -= moveUpDistance
                        UIView.animate(withDuration: animationDuration, animations: { self.globalView.layoutIfNeeded() })
                    } else {
                        self.animateConstraint.constant = self.animateConstraintOriginVal
                        UIView.animate(withDuration: animationDuration, animations: { self.globalView.layoutIfNeeded() })
                    }
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

class TrackingInputAccessoryView: UIView {
    var viewInitMinY: CGFloat!
    var adjustableConst: NSLayoutConstraint!
    var adjustableConstInitValue: CGFloat!
    var animationRootView: UIView!

    init(width: CGFloat, viewInitMinY: CGFloat, adjustableConst: NSLayoutConstraint, animationRootView: UIView) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        self.backgroundColor = UIColor.red
        self.viewInitMinY = viewInitMinY
        self.adjustableConst = adjustableConst
        self.adjustableConstInitValue = adjustableConst.constant
        self.animationRootView = animationRootView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if let superviewObj = self.superview {
            superviewObj.removeObserver(self, forKeyPath: "center")
        }

        if let newSuperviewObj = newSuperview {
            newSuperviewObj.addObserver(self, forKeyPath: "center", options: .new, context: nil)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let superviewObj = self.superview {
            if (object as? UIView == superviewObj && keyPath?.elementsEqual("center") ?? false) {
                let kbFrame = superviewObj.convert(superviewObj.bounds, to: nil)
                let distance = self.viewInitMinY - kbFrame.minY
                self.adjustableConst.constant = self.adjustableConstInitValue - distance
                let duration = TimeInterval(distance / 5000)
                UIView.animate(withDuration: duration, animations: { self.animationRootView.layoutIfNeeded() })
            }
        }
    }
}
