import UIKit

/* TODO List:
    - Complete chat input text field keyboard dismiss animations. [√]
    - Input text field cross line: view integrations.             [>]
    - Chat view cells                                             [-]
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

class ChatViewController: UIViewController, UITableViewDelegate, UITextViewDelegate {
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatBottomElementsView: UIView!
    @IBOutlet weak var chatInputTextView: UITextView!

    @IBOutlet var chatContainerView: UIView!

    @IBOutlet weak var bottomElementsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chatTableViewHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.chatTableView.tableFooterView = nil
        self.chatTableView.separatorStyle = .none
        self.chatTableView.backgroundColor = ColorCollection.ChatViewBackground0
        self.chatTableView.keyboardDismissMode = .interactive

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
    }

    func appendNewMessage() {
    }

    //MARK: UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") { // This is stupid, but works.
            textView.resignFirstResponder()
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        print("new height: \(newSize.height) (current [ \(textView.bounds.width) x \(textView.bounds.height) ])")

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
}
