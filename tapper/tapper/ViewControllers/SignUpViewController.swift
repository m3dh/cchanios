import UIKit
import Fusuma
import os.log

class SignUpViewController: UIViewController, FusumaDelegate {
    static let ViewTagAvatarPicker = 0
    static let ViewTagSuperView = 1

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!

    // MARK: State transitions
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        //
    }

    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        //
    }

    func fusumaCameraRollUnauthorized() {
        //
    }

    // MARK: Inner methods
    func resignAllTextFieldFirstResponder() {
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
}

