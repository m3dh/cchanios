import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // add tap gesture recognizer to hide keyboards.
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleViewGestureTap(_:)))
        self.view.addGestureRecognizer(viewTapGestureRecognizer)

        // load image for the default avatar
        if let defaultAvatar = UIImage(named: "Avatar - Default") {
            self.avatarImageView.image = defaultAvatar
        }

        // set up avatar picker
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.borderWidth = 1.5
        self.avatarImageView.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

    @IBAction func cancelTouchUpInsideAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func handleViewGestureTap(_ sender: UIButton) {
        if self.usernameTextField.isFirstResponder {
            self.usernameTextField.resignFirstResponder()
        }

        if self.displayNameTextField.isFirstResponder {
            self.displayNameTextField.resignFirstResponder()
        }

        if self.passwordTextField.isFirstResponder {
            self.passwordTextField.resignFirstResponder()
        }

        if self.verifyPasswordTextField.isFirstResponder {
            self.verifyPasswordTextField.resignFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

