import UIKit

/* TODO List:
    - Complete chat input text field keyboard dismiss animations. [√]
    - Input text field cross line: view integrations.             [√]
    - Chat view cells                                             [>]
    - Drag & load / refresh                                       [-]
*/

class ChatControllerInputAccessoryView: UIView {
    var viewInitMinY: CGFloat!
    var containerViewFullHeight: CGFloat!
    var messageTableViewHeightConst: NSLayoutConstraint!
    var bottomElementsViewHeightConst: NSLayoutConstraint!
    var animationRootView: UIView!

    init(viewInitMinY: CGFloat,
         rootContainerView: UIView,
         containerViewFullHeight: CGFloat,
         messageTableViewHeightConst: NSLayoutConstraint,
         bottomElementsViewHeightConst: NSLayoutConstraint) {
        super.init(frame: CGRect(x: 0, y: 0, width: rootContainerView.bounds.width, height: 0))
        self.backgroundColor = UIColor.red
        self.viewInitMinY = viewInitMinY
        self.animationRootView = rootContainerView
        self.containerViewFullHeight = containerViewFullHeight
        self.messageTableViewHeightConst = messageTableViewHeightConst
        self.bottomElementsViewHeightConst = bottomElementsViewHeightConst
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if let superviewObj = self.superview {
            superviewObj.removeObserver(self, forKeyPath: "center")
        }

        if let newSuperviewObj = newSuperview {
            newSuperviewObj.addObserver(self, forKeyPath: "center", options: .new, context: nil)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let superviewObj = self.superview {
            if (object as? UIView == superviewObj && keyPath?.elementsEqual("center") ?? false) {
                let kbFrame = superviewObj.convert(superviewObj.bounds, to: nil)
                let distance = self.viewInitMinY - kbFrame.minY
                self.messageTableViewHeightConst.constant = self.containerViewFullHeight - self.bottomElementsViewHeightConst.constant - distance
                let duration = TimeInterval(distance / 5000)
                UIView.animate(withDuration: duration, animations: { self.animationRootView.layoutIfNeeded() })
            }
        }
    }
}

class ChatViewChatMessage {
    var sentAt: Date!
    var messageBody: String!
    var ordinalNumber: Int!
    var senderAccountId: String!
    var uuid: String!

    var textViewSize: CGSize?
    var messageFullHeight: CGFloat?
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    static let ChatSentMessageCellId = "ChatSentMessageCell"
    static let ChatRecvMessageCellId = "ChatRecvMessageCell"

    static let ChatMessageAvatarSize: CGFloat = 40
    static let FullMessageWidthPerct: CGFloat = 0.8
    static let ChatMessageSideMargin: CGFloat = 10
    static let ChatMessageVertMargin: CGFloat = 8

    static let EstimatedChatCellHeight: CGFloat = 50.0

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatBottomElementsView: UIView!
    @IBOutlet weak var chatInputTextView: UITextView!

    @IBOutlet var chatContainerView: UIView!

    @IBOutlet weak var bottomElementsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chatTableViewHeight: NSLayoutConstraint!

    var loadedMessages: [ChatViewChatMessage] = []
    var currentUserAccount: MainAccount!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.chatTableView.register(ChatSentMessageTableCell.self, forCellReuseIdentifier: ChatViewController.ChatSentMessageCellId)
        self.chatTableView.register(ChatRecvMessageTableCell.self, forCellReuseIdentifier: ChatViewController.ChatRecvMessageCellId)

        self.chatTableView.tableFooterView = nil
        self.chatTableView.allowsSelection = false
        self.chatTableView.separatorStyle = .none
        self.chatTableView.backgroundColor = ColorCollection.ChatViewBackground0
        self.chatTableView.keyboardDismissMode = .interactive
        self.chatTableView.estimatedRowHeight = ChatViewController.EstimatedChatCellHeight
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self

        // Setup bottom elements.
        self.chatBottomElementsView.backgroundColor = ColorCollection.ChatElementViewBackground
        self.chatInputTextView.returnKeyType = .send
        self.chatInputTextView.layer.borderWidth = 0
        self.chatInputTextView.backgroundColor = ColorCollection.ChatElementViewBackground

        /* Uncomment this to set text field border color */
        // self.chatInputTextField.layer.borderWidth = 1;
        // self.chatInputTextField.layer.borderColor = UIColor.red.cgColor

        self.chatInputTextView.delegate = self
        self.chatInputTextView.isScrollEnabled = false
        self.chatInputTextView.text = "Message"
        self.chatInputTextView.textColor = .lightGray
        self.chatInputTextView.font = UIFont.init(name: "AvenirNext-DemiBold", size: 13)

        // Manage keyboard interactions.
        let rootViewMaxY = self.view.bounds.maxY
        let navBarHeight = self.navigationController!.navigationBar.frame.height
        let statusHeight = UIApplication.shared.statusBarFrame.height
        let bottomViewHeight = self.bottomElementsViewHeight.constant

        let fullTableViewHeight = rootViewMaxY - navBarHeight - statusHeight - bottomViewHeight

        self.chatTableViewHeight.constant = fullTableViewHeight
        self.chatInputTextView.inputAccessoryView = ChatControllerInputAccessoryView(
            viewInitMinY: self.view.bounds.maxY,
            rootContainerView: self.view,
            containerViewFullHeight: rootViewMaxY - navBarHeight - statusHeight,
            messageTableViewHeightConst: self.chatTableViewHeight,
            bottomElementsViewHeightConst: self.bottomElementsViewHeight)

        self.loadInitChatMessages()
    }

    func loadInitChatMessages() {
        let msg = ChatViewChatMessage()
        msg.messageBody = "欢迎来到出发吧远洋第二季【东南亚四国环线】之旅第三站，泰国。在泰国篇里，我将驾驶着一台柴油版的丰田Hilux皮卡穿越整个泰国全境。今天第11集的故事【泰国的海】就从曼谷展开了。"
        msg.ordinalNumber = 1
        msg.uuid = ">>"
        msg.sentAt = Date()

        self.loadedMessages.append(msg)

        let msg1 = ChatViewChatMessage()
        msg1.messageBody = "传奇"
        msg1.ordinalNumber = 2
        msg1.uuid = ">>>"
        msg1.sentAt = Date()

        self.loadedMessages.append(msg1)

        let msg2 = ChatViewChatMessage()
        msg2.messageBody = "这次试驾的车型都为顶配版本，配备了20英寸的多辐条轮圈，轮胎使用了规格265/40 R20的固特异EAGLE F1 ASYMMETRIC 3系列的轮胎，这个系列的产品侧重点在于车辆的操控、轮胎的附着力等，这似乎要告诉别人，它这次把侧重点放到了驾驶的层面上，并没有一味的追求舒适。的确，全新A8L给人感觉也和奔驰S级那种过于商务气质不同，眼前一辆奔驰经过，我觉得关注的重点还是后排，而当全新A8L停到眼前时，我觉得关注度更多的会在前排。外观部分变化最大的我觉得就是车尾了，横贯整个车尾的OLED尾灯，这次奥迪再次将灯光技术带到了一个新的高度。整个尾灯在夜晚的点亮效果非常吸引人，作为有“灯厂”之称的奥迪这次不负众望啊！这次全新A8L在动力方面全系标配48V轻混技术，之所以使用这套技术，是因为现在的车辆电气设备配备越来越多，之前的12V蓄电池已经不足以应对越来越高的用电需求了。当然，48V轻混的加入也让全新A8L在日常使用中可以降低燃油消耗，根据官方资料，它的百公里燃油消耗能降低0.7L左右。这台3.0T发动机从1370rpm开始便可以提供最大的扭矩输出，涡轮正式介入的转速比较低，让车辆开起来感觉很平顺，起步时油门反应不那么敏感，这点我觉得很好，可以让车辆非常平稳的起步。动力方面，一旦车辆行驶起来不会像起步时那么慵懒，所以起步有点肉的感觉可以说只是假象，目的很简单就是为了让起步时更加缓和，别忘了，后排可是要坐老板的！"
        msg2.ordinalNumber = 2
        msg2.uuid = ">>>"
        msg2.sentAt = Date()
        self.loadedMessages.append(msg2)
    }

    func isRecvMessageSenderAvatarNeeded() -> Bool {
        return true // For testing...
    }

    func isSentMessage(message: ChatMessage) -> Bool {
        return false
    }

    //MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") { // This is stupid, but works.
            textView.resignFirstResponder() // Consider not resign first responder?
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = max(40, newSize.height + 8)
        if newHeight != self.bottomElementsViewHeight.constant {
            let newTableHeight = self.chatTableViewHeight.constant - newHeight + self.bottomElementsViewHeight.constant
            self.bottomElementsViewHeight.constant = newHeight
            self.chatTableViewHeight.constant = newTableHeight // this is not correct! > integrate with tracker.
        }
    }

    func textViewDidEndEditing (_ textView: UITextView) {
        if let text = textView.text {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                textView.text = "Message"
                textView.textColor = .lightGray
            }
        }
    }

    func textViewDidBeginEditing (_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .darkGray
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.loadedMessages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.loadedMessages[indexPath.row]

        // if is sent message
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatViewController.ChatSentMessageCellId, for: indexPath) as UITableViewCell
        if let chatSentCell = cell as? ChatSentMessageTableCell {
            chatSentCell.load(message: message)
        }

        cell.backgroundColor = UIColor.clear
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.loadedMessages[indexPath.row]
        if let fullHeight = message.messageFullHeight {
            return fullHeight
        } else {
            return ChatViewController.EstimatedChatCellHeight
        }
    }
}
