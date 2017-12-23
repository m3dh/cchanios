import UIKit
import os.log

class SignInViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // add tap gesture recognizer to hide keyboards.
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleViewGestureTap(_:)))
        viewTapGestureRecognizer.isEnabled = true
        self.view.addGestureRecognizer(viewTapGestureRecognizer)
        self.view.isUserInteractionEnabled = true

        // disable sign in button by default
        self.signInButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func handleViewGestureTap(_: UITapGestureRecognizer) {
        if self.usernameTextField.isFirstResponder {
            self.usernameTextField.resignFirstResponder()
        }

        if self.passwordTextField.isFirstResponder {
            self.passwordTextField.resignFirstResponder()
        }
    }

    @IBAction func signInTouchUpInsideAction(_ sender: UIButton) {
    }

    @IBAction func unwindToSignInViewNormally(sender: UIStoryboardSegue) {
        os_log("Unwind to sign in view (normally)")
    }
}
