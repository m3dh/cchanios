import UIKit
import Fusuma
import os.log

class SignUpViewController: UIViewController, FusumaDelegate, UITextFieldDelegate {
    static let ViewTagAvatarPicker = 0
    static let ViewTagSuperView = 1

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var inputStackViewTopConst: NSLayoutConstraint!

    var inputStackViewProtector: KeyboardFrameChangeProtector! = nil
    var allTextfields: [UITextField]! = nil

    // MARK: State transitions
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // remove all registered observers
        NotificationCenter.default.removeObserver(self.inputStackViewProtector, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self.inputStackViewProtector, name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // setup keyboard show / hide notification
        inputStackViewProtector = KeyboardFrameChangeProtector(protectView: self.inputStackView, globalView: self.view, animateConstraint: self.inputStackViewTopConst)
        NotificationCenter.default.addObserver(self.inputStackViewProtector, selector: #selector(inputStackViewProtector.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self.inputStackViewProtector, selector: #selector(inputStackViewProtector.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // load image for the default avatar
        if let defaultAvatar = UIImage(named: "Avatar - Default") {
            self.avatarImageView.image = defaultAvatar
        }

        // set up avatar picker
        let avatarPickerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleViewGestureTap(_:)))
        self.avatarImageView.tag = SignUpViewController.ViewTagAvatarPicker
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.borderWidth = 1.5
        self.avatarImageView.layer.borderColor = UIColor.darkGray.cgColor
        self.avatarImageView.isUserInteractionEnabled = true
        self.avatarImageView.addGestureRecognizer(avatarPickerTapRecognizer)

        // add tap gesture recognizer to hide keyboards.
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleViewGestureTap(_:)))
        self.view.tag = SignUpViewController.ViewTagSuperView
        self.view.addGestureRecognizer(viewTapGestureRecognizer)

        // disable signup button
        self.signUpButton.isEnabled = false

        // setup all text fields
        self.usernameTextField.delegate = self
        self.displayNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.verifyPasswordTextField.delegate = self
        self.allTextfields = [self.usernameTextField, self.displayNameTextField, self.passwordTextField, self.verifyPasswordTextField]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

    @IBAction func cancelTouchUpInsideAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func handleViewGestureTap(_ sender: UITapGestureRecognizer) {
        self.resignAllTextFieldFirstResponder()
        if let senderView = sender.view {
            if senderView.tag == SignUpViewController.ViewTagAvatarPicker {
                self.showAvatarImagePicker()
            }
        }
    }

    func showAvatarImagePicker() {
        let controller = FusumaViewController()
        controller.allowMultipleSelection = false
        controller.availableModes = [.library, .camera]
        controller.isStatusBarHiddenPreferred = false
        controller.isAlbumViewShadowPreferred = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }

    // MARK: Protocol FusumaDelegate
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        self.avatarImageView.image = image
    }

    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        // Empty
    }

    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        // Empty
    }

    func fusumaCameraRollUnauthorized() {
        // Empty
    }

    // MARK: Protocol UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resignAllTextFieldFirstResponder()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.tryEnableSignUpButton()
        return true
    }

    // MARK: Text field operations
    func resignAllTextFieldFirstResponder() {
        for textField in self.allTextfields {
            if textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }

    func tryEnableSignUpButton() {
        if self.usernameTextField.text?.isEmpty == false && self.displayNameTextField.text?.isEmpty == false
        && self.passwordTextField.text?.isEmpty == false && self.verifyPasswordTextField.text?.isEmpty == false {
            self.signUpButton.isEnabled = true
        } else {
            self.signUpButton.isEnabled = false
        }
    }
}

