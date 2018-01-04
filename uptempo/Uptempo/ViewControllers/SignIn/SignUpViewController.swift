import UIKit
import Fusuma
import os.log

class SignUpViewController: UIViewController, FusumaDelegate, UITextFieldDelegate {
    static let ViewTagAvatarPicker = 0
    static let ViewTagSuperView = 1
    static let ViewTagDisplayName = 2

    @IBOutlet weak var signUpButton: ColorfulButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var errorMessageLabelHeightConst: NSLayoutConstraint!

    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var inputStackViewTopConst: NSLayoutConstraint!

    var inputStackViewProtector: KeyboardFrameChangeProtector! = nil
    var allTextfields: [UITextField]! = nil

    // MARK: State transitions
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        super.viewWillAppear(animated)
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
        self.inputStackViewProtector = KeyboardFrameChangeProtector(protectView: self.inputStackView, globalView: self.view, animateConstraint: self.inputStackViewTopConst)
        NotificationCenter.default.addObserver(self.inputStackViewProtector, selector: #selector(inputStackViewProtector.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self.inputStackViewProtector, selector: #selector(inputStackViewProtector.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // misc.
        self.errorMessageLabel.textColor = UIColor.red
        self.signUpButton.isPrimary = true

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
        // self.signUpButton.isEnabled = false

        // setup all text fields
        self.usernameTextField.delegate = self
        self.displayNameTextField.tag = SignUpViewController.ViewTagDisplayName
        self.displayNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.verifyPasswordTextField.delegate = self
        self.allTextfields = [self.usernameTextField, self.displayNameTextField, self.passwordTextField, self.verifyPasswordTextField]
    }

    override func viewDidLayoutSubviews() {
        self.inputStackViewProtector?.protectViewSizeChanged()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

    @IBAction func signUpTouchUpInsideAction(_ sender: UIButton) {
        if !self.checkIfAllFieldsAreValid() {
            return
        }

        let avatarImage = self.avatarImageView.image!
        let newImage = ImageHelper.resizeSquareImageForAvatarUsage(image: avatarImage)

        self.avatarImageView.image = newImage
        self.resignAllTextFieldFirstResponder()
        OperationHelper.startAsyncJobAndBlockCurrentWindow(
            window: self,
            task: { () -> Bool in
                // TODO: shall use a real result
                return true
            },
            message: "Signing up...", completion: { ()->() in
                let controllers = self.navigationController!.viewControllers
                for controller in controllers {
                    if let c = controller as? SignInViewController {
                        c.unwindFromSignUpViewController(sourceViewController: self)
                        self.navigationController!.popToViewController(c, animated: true)
                    }
                }})
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
        if self.checkIfAllFieldsAreNotEmpty() {
            self.signUpButton.isEnabled = true
        } else {
            self.signUpButton.isEnabled = false
        }
    }

    func checkIfAllFieldsAreNotEmpty() -> Bool {
        for textfield in self.allTextfields {
            if textfield.text?.isEmpty == true {
                return false
            }
        }

        return true
    }

    func checkIfAllFieldsAreValid() -> Bool {
        if !self.checkIfAllFieldsAreNotEmpty() {
            return false
        }

        self.errorMessageLabel.text = nil
        for textfield in self.allTextfields {
            UIControlHelper.resetTextFieldStyle(textfield: textfield)
        }

        if let imgSize = self.avatarImageView.image?.size {
            if imgSize.height * self.avatarImageView.image!.scale < ImageHelper.expectedAvatarWidthAndHeight || imgSize.width * self.avatarImageView.image!.scale < ImageHelper.expectedAvatarWidthAndHeight {
                UIControlHelper.safelySetUILabelText(
                    label: self.errorMessageLabel,
                    labelHeight: self.errorMessageLabelHeightConst,
                    text: "Invalid avatar picture : shall be bigger than 240pix x 240pix.")
                return false
            } else {
                print("Sign up with image size : \(imgSize.height * self.avatarImageView.image!.scale) x \(imgSize.width * self.avatarImageView.image!.scale)")
            }
        }

        if self.usernameTextField.text?.range(of: "^[a-zA-Z]\\w{3,10}$", options: .regularExpression) == nil {
            UIControlHelper.safelySetUILabelText(
                label: self.errorMessageLabel,
                labelHeight: self.errorMessageLabelHeightConst,
                text: "Invalid username: user name shall be 4-10 alphanumeric strings.")
            UIControlHelper.markTextFieldError(textfield: self.usernameTextField)
            return false
        }

        if self.passwordTextField.text?.range(of: "[a-zA-Z0-9!@#$%^&*]{6,20}", options: .regularExpression) == nil {
            UIControlHelper.safelySetUILabelText(
                label: self.errorMessageLabel,
                labelHeight: self.errorMessageLabelHeightConst,
                text: "Invalid password: password shall be 6-20 with only alphanumeric or @, #, $, %, ^, & charactors")
            UIControlHelper.markTextFieldError(textfield: self.passwordTextField)
            return false
        }

        if self.displayNameTextField.text!.count >= 15 {
            UIControlHelper.safelySetUILabelText(
                label: self.errorMessageLabel,
                labelHeight: self.errorMessageLabelHeightConst,
                text: "Invalid display name: display name shall have less than 20 charactors")
            UIControlHelper.markTextFieldError(textfield: self.displayNameTextField)
            return false
        }

        if self.passwordTextField.text! != self.verifyPasswordTextField.text! {
            UIControlHelper.safelySetUILabelText(
                label: self.errorMessageLabel,
                labelHeight: self.errorMessageLabelHeightConst,
                text: "Confirm password does not match the password.")
            UIControlHelper.markTextFieldError(textfield: self.verifyPasswordTextField)
            return false
        }

        return true
    }
}

