import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var chatInputTextField: UITextField!
    @IBOutlet weak var chatBottomElementsView: UIView!
    @IBOutlet weak var chatContainerView: UIView!
    @IBOutlet weak var chatTableView: UITableView!

    override func viewDidLoad() {
        self.chatTableView.tableFooterView = nil
        self.chatTableView.separatorStyle = .none
        self.chatTableView.backgroundColor = ColorCollection.ChatViewBackground0

        self.chatBottomElementsView.backgroundColor = ColorCollection.ChatElementViewBackground

        self.chatInputTextField.returnKeyType = .send
    }
}
