import UIKit

class ChatSentMessageTableCell : UITableViewCell {
    var initialized = false

    var messageBodyView: UITextView!
    var messageBodyContainer: UIView!
    var messageContainerViewWidth: NSLayoutConstraint!

    func load(message: ChatViewChatMessage) {
        if !self.initialized {
            self.messageBodyContainer = UIView()
            self.contentView.addSubview(self.messageBodyContainer)
            self.messageBodyContainer.translatesAutoresizingMaskIntoConstraints = false
            self.messageBodyContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: ChatViewController.ChatMessageVertMargin).isActive = true
            self.messageBodyContainer.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor,
                constant: -ChatViewController.ChatMessageVertMargin).isActive = true
            self.messageBodyContainer.rightAnchor.constraint(
                equalTo: self.contentView.rightAnchor,
                constant: -ChatViewController.ChatMessageSideMargin).isActive = true
            self.messageContainerViewWidth = self.messageBodyContainer.widthAnchor.constraint(equalToConstant: 150)
            self.messageContainerViewWidth.isActive = true
            self.messageBodyContainer.backgroundColor = UIColor.white
            self.messageBodyContainer.layer.cornerRadius = 5.0
            self.messageBodyContainer.layer.masksToBounds = true
            self.messageBodyContainer.backgroundColor = ColorCollection.ChatSentMessageBackground

            self.messageBodyView = UITextView()
            self.messageBodyView.isEditable = false
            self.messageBodyView.isScrollEnabled = false
            self.messageBodyContainer.addSubview(self.messageBodyView)
            self.messageBodyView.translatesAutoresizingMaskIntoConstraints = false
            self.messageBodyView.topAnchor.constraint(equalTo: self.messageBodyContainer.topAnchor, constant: 0).isActive = true
            self.messageBodyView.bottomAnchor.constraint(equalTo: self.messageBodyContainer.bottomAnchor, constant: 0).isActive = true
            self.messageBodyView.rightAnchor.constraint(
                equalTo: self.messageBodyContainer.rightAnchor,
                constant: -ChatViewController.ChatMessageSideMargin).isActive = true // Double right margin
            self.messageBodyView.leftAnchor.constraint(
                equalTo: self.messageBodyContainer.leftAnchor,
                constant: ChatViewController.ChatMessageSideMargin).isActive = true
            self.messageBodyView.backgroundColor = ColorCollection.ChatSentMessageBackground
            self.messageBodyView.textColor = ColorCollection.Black
            self.messageBodyView.font = UIFont.init(name: "Avenir-Medium", size: 13)
            self.initialized = true
        }

        self.messageBodyView.text = message.messageBody
        if let actualSize = message.textViewSize {
            self.messageContainerViewWidth.constant = actualSize.width + 2 * ChatViewController.ChatMessageSideMargin
        } else {
            let maxWidth = self.contentView.bounds.width * ChatViewController.FullMessageWidthPerct - 3 * ChatViewController.ChatMessageSideMargin
            let newSize = self.messageBodyView.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
            self.messageContainerViewWidth.constant = newSize.width + 2 * ChatViewController.ChatMessageSideMargin
            message.textViewSize = newSize
            message.messageFullHeight = newSize.height + ChatViewController.ChatMessageVertMargin * 2
        }
    }
}

class ChatRecvMessageTableCell : UITableViewCell {
    var initialized = false

    var messageBodyView: UITextView!

    func load(message: ChatViewChatMessage) {
        if !self.initialized {
            self.messageBodyView = UITextView()
        }
    }
}
