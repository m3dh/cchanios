import UIKit

/* TODO List:
    - Complete chat input text field keyboard dismiss animations. [>]
    - Input text field cross line: view integrations.             [>]
*/

class ChatViewController: UIViewController, UITableViewDelegate {
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
        self.chatTableView.keyboardDismissMode = .interactive
        self.chatBottomElementsView.backgroundColor = ColorCollection.ChatElementViewBackground
        self.chatInputTextField.returnKeyType = .send
        self.chatInputTextField.borderStyle = .none

        /* Uncomment this to set text field border color */
        // self.chatInputTextField.layer.borderWidth = 1;
        // self.chatInputTextField.layer.borderColor = UIColor.red.cgColor

        self.chatInputTextField.placeholder = "Message"
        self.chatInputTextField.font = UIFont.init(name: "AvenirNext-DemiBold", size: 13)

        // Manage keyboard interactions.
        let rootViewMaxY = self.view.bounds.maxY
        let navBarHeight = self.navigationController!.navigationBar.frame.height
        let statusHeight = UIApplication.shared.statusBarFrame.height
        self.fullTableViewHeight = rootViewMaxY - navBarHeight - statusHeight - 40 /* height of bottom elements */
        self.chatTableViewHeight.constant = self.fullTableViewHeight

        let tracker = TrackingInputAccessoryView(
            width: self.chatContainerView.bounds.width,
            viewInitMinY: rootViewMaxY,
            adjustableConst: self.chatTableViewHeight,
            animationRootView: self.view)
        self.chatInputTextField.inputAccessoryView = tracker
    }
}
