import UIKit
import os.log

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var errorMessageLabelHeightConst: NSLayoutConstraint!

    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var inputStackViewTopConst: NSLayoutConstraint!

    var inputStackViewProtector: KeyboardFrameChangeProtector! = nil
    var avatarImageView: UIImageView? = nil

    // MARK: State transitions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // remove all registered observers
        NotificationCenter.default.removeObserver(self.inputStackViewProtector, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self.inputStackViewProtector, name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // setup keyboard show / hide notification
        self.inputStackView.translatesAutoresizingMaskIntoConstraints = false
        self.inputStackViewProtector = KeyboardFrameChangeProtector(protectView: self.inputStackView, globalView: self.view, animateConstraint: self.inputStackViewTopConst)
        NotificationCenter.default.addObserver(self.inputStackViewProtector, selector: #selector(inputStackViewProtector.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self.inputStackViewProtector, selector: #selector(inputStackViewProtector.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

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

    override func viewDidLayoutSubviews() {
        self.inputStackViewProtector?.protectViewSizeChanged()
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

    // MARK: Private methods
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

    func tryLoadAccountInfo() {

    }

    func saveAccountInfo() {

    }

    @IBAction func unwindToSignInViewNormally(sender: UIStoryboardSegue) {
        if let source = sender.source as? SignUpViewController {
            UIControlHelper.safelySetUILabelText(
                label: self.errorMessageLabel,
                labelHeight: self.errorMessageLabelHeightConst,
                text: "")
            self.usernameTextField.text = source.usernameTextField.text
            self.passwordTextField.text = source.passwordTextField.text
            if let avatarImage = source.avatarImageView.image {
                if self.avatarImageView == nil {
                    self.avatarImageView = UIImageView(image: avatarImage)
                    self.inputStackView.insertArrangedSubview(self.avatarImageView!, at: 1)
                    self.avatarImageView!.widthAnchor.constraint(equalToConstant: 100.0).isActive = true
                    self.avatarImageView!.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
                    self.avatarImageView!.layer.cornerRadius = 50.0
                    self.avatarImageView!.layer.masksToBounds = true
                    self.avatarImageView!.layer.borderWidth = 1.5
                    self.avatarImageView!.layer.borderColor = UIColor.darkGray.cgColor
                } else {
                    self.avatarImageView!.image = avatarImage
                }
            }
        }
    }
}
