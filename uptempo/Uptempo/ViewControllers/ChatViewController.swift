import UIKit

class ChatViewController: UIViewController {
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatBottomElementsView: UIView!
    @IBOutlet weak var chatInputTextField: UITextField!

    @IBOutlet var chatContainerView: UIView!
    @IBOutlet weak var chatTableViewHeight: NSLayoutConstraint!

    var fullTableViewHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.chatTableView.tableFooterView = nil
        self.chatTableView.separatorStyle = .none
        self.chatTableView.backgroundColor = ColorCollection.ChatViewBackground0
        self.chatBottomElementsView.backgroundColor = ColorCollection.ChatElementViewBackground
        self.chatInputTextField.returnKeyType = .send

        let navBarHeight = self.navigationController!.navigationBar.frame.height
        let statusHeight = UIApplication.shared.statusBarFrame.height
        let knownContainerHeight = self.chatContainerView.frame.height
        self.fullTableViewHeight = knownContainerHeight - navBarHeight - statusHeight - 40 /* height of bottom elements */
        self.chatTableViewHeight.constant = self.fullTableViewHeight
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.chatTableViewHeight.constant = self.fullTableViewHeight - keyboardHeight
            UIView.animate(withDuration: 0.1, animations: { self.view.layoutIfNeeded() })
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        self.chatTableViewHeight.constant = self.fullTableViewHeight
        UIView.animate(withDuration: 0.2, animations: { self.view.layoutIfNeeded() })
    }
}
