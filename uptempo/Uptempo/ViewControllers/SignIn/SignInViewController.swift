import UIKit
import os.log

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: ColorfulButton!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var errorMessageLabelHeightConst: NSLayoutConstraint!
    
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var inputStackViewTopConst: NSLayoutConstraint!
    
    var inputStackViewProtector: KeyboardFrameChangeProtector! = nil
    var avatarImageView: UIImageView? = nil
    
    // MARK: State transitions
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: false)
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
        self.inputStackView.translatesAutoresizingMaskIntoConstraints = false
        self.inputStackViewProtector = KeyboardFrameChangeProtector(protectView: self.inputStackView, globalView: self.view, animateConstraint: self.inputStackViewTopConst)
        NotificationCenter.default.addObserver(self.inputStackViewProtector, selector: #selector(inputStackViewProtector.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self.inputStackViewProtector, selector: #selector(inputStackViewProtector.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorMessageLabel.textColor = UIColor.red

        // add tap gesture recognizer to hide keyboards.
        let viewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleViewGestureTap(_:)))
        self.view.addGestureRecognizer(viewTapGestureRecognizer)
        
        // setup delegation for all text fields
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
        // disable sign in button by default
        self.signInButton.isPrimary = true
        self.signInButton.isEnabled = false

        let mainAccount = ResourceManager.accountMgr.getStoreActiveMainAccount()
        if let avatarImageData = mainAccount?.avatarImageData {
            let avatarImage = UIImage(data: avatarImageData)!
            self.setAvatarImageView(avatarImage: avatarImage)
        }

        if let mainAccountName = mainAccount?.accountUserName {
            self.usernameTextField.text = mainAccountName
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.inputStackViewProtector?.protectViewSizeChanged()
    }
    
    @objc func handleViewGestureTap(_: UITapGestureRecognizer) {
        self.resignAllTextFieldFirstResponder()
    }
    
    @IBAction func signInTouchUpInsideAction(_ sender: UIButton) {
        self.resignAllTextFieldFirstResponder()
        let accountName = self.usernameTextField.text!
        UIControlHelper.startAsyncTaskAndBlockCurrentWindow(
            window: self,
            task: { (completion: @escaping(Bool)->Void) -> Void in
                let webErrorHandler = WebErrorHandler()
                webErrorHandler.upperCompletion = completion
                webErrorHandler.addHandler(code: 404, handler: { (msg) -> Bool in
                    UIControlHelper.safelySetUILabelText(
                        label: self.errorMessageLabel,
                        labelHeight: self.errorMessageLabelHeightConst,
                        text: NSLocalizedString("SignIn_NotFound", comment: "UserNameNotFound"))
                    UIControlHelper.markTextFieldError(textfield: self.usernameTextField)
                    return true
                })

                // Get user account from service to verify (and fill necessary info)
                ResourceManager.accountMgr.getUserAccount(
                    accountName: accountName,
                    completion: {account in
                        let localMainAccount = ResourceManager.accountMgr.getStoreMainAccount(username: accountName)
                        let localDeviceId = localMainAccount?.authDeviceId.value

                        let webErrorHandler1 = WebErrorHandler()
                        webErrorHandler1.upperCompletion = completion
                        webErrorHandler1.addHandler(code: 401, handler: { (msg) -> Bool in
                            UIControlHelper.safelySetUILabelText(
                                label: self.errorMessageLabel,
                                labelHeight: self.errorMessageLabelHeightConst,
                                text: NSLocalizedString("SignIn_Unauthorized", comment: "UserPasswordError"))
                            UIControlHelper.markTextFieldError(textfield: self.passwordTextField)
                            return true
                        })

                        // Logon user account.
                        ResourceManager.accountMgr.logonMainAccount(
                            accountName: account.accountId,
                            passwordHash: SecretHelper.fillUserAccountPassword(createdAt: account.createdAt, password: self.passwordTextField.text!),
                            deviceId: localDeviceId,
                            completion: { token in
                                if let localMainAccountObj = localMainAccount {
                                    ResourceManager.accountMgr.setStoreMainAccountAuthInfo(
                                        account: localMainAccountObj,
                                        authToken: token.token,
                                        authDeviceId: token.deviceId)
                                } else {
                                    ResourceManager.accountMgr.createStoreMainAccount(
                                        accountId: account.accountId,
                                        username: accountName,
                                        createdAt: account.createdAt,
                                        authDeviceId: token.deviceId,
                                        authToken: token.token)
                                }

                                let storedMainAccount = ResourceManager.accountMgr.getStoreMainAccount(username: accountName)!
                                self.refreshMainAccountAvatar(mainAccount: storedMainAccount, completion: completion)
                        }, handler: webErrorHandler1)
                }, handler: webErrorHandler)
        },
            message: NSLocalizedString("Popup_SigningIn", comment: "SignInPop"), completion: { ()->() in
                self.performSegue(withIdentifier: "unwindToMainView", sender: nil)})
    }

    func refreshMainAccountAvatar(mainAccount: MainAccount, completion: @escaping (Bool)->Void) {
        if let avatarImageId = mainAccount.avatarImageId {
            // Fetch the server side avatar image data.
            let webErrorHandler = WebErrorHandler()
            ResourceManager.imageMgr.getCoreImage(
                mainAccount: mainAccount,
                coreImageId: avatarImageId,
                completion: {img in
                    ResourceManager.accountMgr.setStoreMainAccountAvatar(account: mainAccount, imageId: img.baseImageId, imageData: img.imageData!)
                    completion(true)
            }, handler: webErrorHandler)
        } else if let avatarImage = self.avatarImageView?.image {
            // Upload the avatar image (on registration)
            let webErrorHandler = WebErrorHandler()
            let jpegData = UIImageJPEGRepresentation(avatarImage, 1)!
            ResourceManager.imageMgr.createCoreJpegImage(
                mainAccount: mainAccount,
                jpegImageData: jpegData,
                completion: {(img) in
                    ResourceManager.accountMgr.updateMainAccount(
                        mainAccount: mainAccount,
                        displayName: nil,
                        avatarImageId: img.baseImageId,
                        completion: {(account) in
                            ResourceManager.accountMgr.setStoreMainAccountAvatar(account: mainAccount, imageId: img.baseImageId, imageData: jpegData)
                            completion(true)
                    }, handler: webErrorHandler)
            }, handler: webErrorHandler)
        }
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
            self.errorMessageLabel.text = nil
            self.signInButton.isEnabled = true
        } else {
            self.signInButton.isEnabled = false
        }
    }
    
    func unwindFromSignUpViewController(sourceViewController: SignUpViewController?) {
        if let source = sourceViewController {
            UIControlHelper.safelySetUILabelText(
                label: self.errorMessageLabel,
                labelHeight: self.errorMessageLabelHeightConst,
                text: "")
            self.usernameTextField.text = source.usernameTextField.text
            self.passwordTextField.text = source.passwordTextField.text
            if let avatarImage = source.avatarImageView.image {
                self.setAvatarImageView(avatarImage: avatarImage)
            }

            self.tryEnableSignInButton()
        }
    }

    func setAvatarImageView(avatarImage: UIImage) {
        if self.avatarImageView == nil {
            self.avatarImageView = UIImageView(image: avatarImage)
            self.inputStackView.insertArrangedSubview(self.avatarImageView!, at: 2)
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
