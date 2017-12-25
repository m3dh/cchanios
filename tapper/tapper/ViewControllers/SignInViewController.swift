import UIKit
import os.log

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // add tap gesture recognizer to hide keyboards.
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleViewGestureTap(_:)))
        self.view.addGestureRecognizer(viewTapGestureRecognizer)

        // setup delegation for all text fields
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self

        // disable sign in button by default
        self.signInButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func handleViewGestureTap(_: UITapGestureRecognizer) {
        self.resignAllTextFieldFirstResponder()
    }

    @IBAction func signInTouchUpInsideAction(_ sender: UIButton) {
        self.tryEnableSignInButton()
    }

    // MARK: Protocol UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignAllTextFieldFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resignAllTextFieldFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.tryEnableSignInButton()
        return true
    }

    // MARK: State transitions
    func resignAllTextFieldFirstResponder() {
        if self.usernameTextField.isFirstResponder {
            self.usernameTextField.resignFirstResponder()
        }

        if self.passwordTextField.isFirstResponder {
            self.passwordTextField.resignFirstResponder()
        }
    }

    func tryEnableSignInButton() {
        if self.usernameTextField.text?.isEmpty == false && self.passwordTextField.text?.isEmpty == false {
            self.signInButton.isEnabled = true
        } else {
            self.signInButton.isEnabled = false
        }
    }

    @IBAction func unwindToSignInViewNormally(sender: UIStoryboardSegue) {
        print("Goes back from sender!")
        if let source = sender.source as? SignUpViewController {
            print("Goes back from SignUp! \(source.passwordTextField.text!)")
        }
    }
}
