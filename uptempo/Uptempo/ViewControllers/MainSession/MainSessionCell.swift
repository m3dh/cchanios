import UIKit

class MainSessionCell: UITableViewCell {
    var avatarImageView: ShadowAvatarView!
    var titleTextView: UILabel!
    var messageTextView: UILabel!
    var timestampTextView: UILabel!

    var symbolUnreadCountView: UILabel!
    var symbolUnreadCountViewWidthConst: NSLayoutConstraint!

    var timeAndOtherSymbolView: UIView!
    var timeAndOtherSymbolViewWidthConst: NSLayoutConstraint!

    var titleAndMessageView: UIView!
    var titleAndMessageViewWidthConst: NSLayoutConstraint!

    func load(avatar: UIImage, titleText: String, msgText: String, unreadCount: Int, lastMsgTime: Date) {
        let viewFullHeight: CGFloat = 72
        self.timeAndOtherSymbolView = UIView()
        self.titleAndMessageView = UIView()

        // avatar view (height: 50)
        let avatarHeight: CGFloat = 50
        self.avatarImageView = ShadowAvatarView()
        self.contentView.addSubview(self.avatarImageView)
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.heightAnchor.constraint(equalToConstant: avatarHeight).isActive = true
        self.avatarImageView.widthAnchor.constraint(equalToConstant: avatarHeight).isActive = true
        self.avatarImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (viewFullHeight - avatarHeight) / 2).isActive = true
        self.avatarImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: (viewFullHeight - avatarHeight) / 2).isActive = true
        self.avatarImageView.initialize(size: avatarHeight, shadowPercent: 1.0)

        self.avatarImageView.avatarImage = avatar
        self.avatarImageView.borderColor = ColorCollection.UserAvatarBorder0.cgColor // UIColor(white: 0.92, alpha: 1).cgColor

        // time and other symbol view
        let timeAndSymbolHeight: CGFloat = 52
        self.contentView.addSubview(self.timeAndOtherSymbolView)
        self.timeAndOtherSymbolView.translatesAutoresizingMaskIntoConstraints = false
        self.timeAndOtherSymbolView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -15).isActive = true
        self.timeAndOtherSymbolView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (viewFullHeight - timeAndSymbolHeight) / 2).isActive = true
        self.timeAndOtherSymbolView.heightAnchor.constraint(equalToConstant: timeAndSymbolHeight).isActive = true

        // datetime text
        self.timestampTextView = UILabel()
        self.timeAndOtherSymbolView.addSubview(self.timestampTextView)
        self.timestampTextView.translatesAutoresizingMaskIntoConstraints = false
        self.timestampTextView.rightAnchor.constraint(equalTo: self.timeAndOtherSymbolView.rightAnchor).isActive = true
        self.timestampTextView.topAnchor.constraint(equalTo: self.timeAndOtherSymbolView.topAnchor).isActive = true
        self.timestampTextView.font = UIFont.init(name: "AvenirNext-DemiBold", size: 11)
        self.timestampTextView.text = self.getRightDateString(time: lastMsgTime)
        self.timestampTextView.textColor = ColorCollection.TableViewTimestamp
        let size = self.timestampTextView.sizeThatFits(self.timestampTextView.bounds.size)
        self.timestampTextView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        self.timeAndOtherSymbolViewWidthConst = self.timeAndOtherSymbolView.widthAnchor.constraint(equalToConstant: 10)
        self.timeAndOtherSymbolViewWidthConst.isActive = true

        // symbol view (unread)
        self.symbolUnreadCountView = UILabel()
        self.timeAndOtherSymbolView.addSubview(self.symbolUnreadCountView)
        self.symbolUnreadCountView.text = " "
        self.symbolUnreadCountView.translatesAutoresizingMaskIntoConstraints = false
        self.symbolUnreadCountView.rightAnchor.constraint(equalTo: self.timeAndOtherSymbolView.rightAnchor, constant: -2).isActive = true
        self.symbolUnreadCountView.bottomAnchor.constraint(equalTo: self.timeAndOtherSymbolView.bottomAnchor, constant: -5).isActive = true
        self.symbolUnreadCountView.font = UIFont.init(name: "AvenirNext-DemiBold", size: 11)
        self.symbolUnreadCountView.heightAnchor.constraint(equalToConstant: self.symbolUnreadCountView.sizeThatFits(self.symbolUnreadCountView.bounds.size).height)
        self.symbolUnreadCountViewWidthConst = self.symbolUnreadCountView.widthAnchor.constraint(equalToConstant: 5)
        self.symbolUnreadCountViewWidthConst.isActive = true
        self.symbolUnreadCountView.textAlignment = .center
        if unreadCount > 0 {
            self.symbolUnreadCountView.text = String(unreadCount)
        } else {
            self.symbolUnreadCountView.text = ""
        }

        // title and message view
        let titleMsgHeight: CGFloat = 52
        self.contentView.addSubview(self.titleAndMessageView)
        self.titleAndMessageView.translatesAutoresizingMaskIntoConstraints = false
        self.titleAndMessageView.leftAnchor.constraint(equalTo: self.avatarImageView.rightAnchor, constant: 15).isActive = true
        self.titleAndMessageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (viewFullHeight - titleMsgHeight) / 2).isActive = true
        self.titleAndMessageView.heightAnchor.constraint(equalToConstant: titleMsgHeight).isActive = true
        self.titleAndMessageViewWidthConst = self.titleAndMessageView.widthAnchor.constraint(equalToConstant: 10)
        self.titleAndMessageViewWidthConst.isActive = true

        let bufferOffset = (viewFullHeight - avatarHeight) / 2 + 15 + 1
        self.setViewWidths(avatarWidth: avatarHeight, offset: bufferOffset)

        // title text view
        self.titleTextView = UILabel()
        self.titleTextView.font = UIFont.init(name: "AvenirNext-DemiBold", size: 14)
        self.titleTextView.textColor = ColorCollection.Black
        self.titleTextView.text = titleText
        self.titleAndMessageView.addSubview(self.titleTextView)
        self.titleTextView.translatesAutoresizingMaskIntoConstraints = false
        self.titleTextView.leftAnchor.constraint(equalTo: self.titleAndMessageView.leftAnchor).isActive = true
        self.titleTextView.rightAnchor.constraint(equalTo: self.titleAndMessageView.rightAnchor).isActive = true
        self.titleTextView.topAnchor.constraint(equalTo: self.titleAndMessageView.topAnchor).isActive = true

        // message text view
        self.messageTextView = UILabel()
        self.messageTextView.font = UIFont.init(name: "Avenir-Medium", size: 13)
        self.messageTextView.textColor = ColorCollection.LightGrey
        self.messageTextView.text = msgText
        self.messageTextView.numberOfLines = 2
        self.titleAndMessageView.addSubview(self.messageTextView)
        self.messageTextView.translatesAutoresizingMaskIntoConstraints = false
        self.messageTextView.leftAnchor.constraint(equalTo: self.titleAndMessageView.leftAnchor).isActive = true
        self.messageTextView.rightAnchor.constraint(equalTo: self.titleAndMessageView.rightAnchor).isActive = true
        self.messageTextView.topAnchor.constraint(equalTo: self.titleTextView.bottomAnchor).isActive = true
    }

    func setViewWidths(avatarWidth: CGFloat, offset: CGFloat) {
        // TODO: get max from time / symbol label
        let size = self.timestampTextView.sizeThatFits(self.timestampTextView.bounds.size)
        self.timeAndOtherSymbolViewWidthConst.constant = size.width

        // reset title and message width
        let titleAndMsgWidth = self.contentView.bounds.width - avatarWidth - (size.width + 8) - offset
        self.titleAndMessageViewWidthConst.constant = titleAndMsgWidth

        // set unread count view
        if self.symbolUnreadCountView.text?.isEmpty == false {
            let fitSize = self.symbolUnreadCountView.sizeThatFits(self.symbolUnreadCountView.bounds.size)
            self.symbolUnreadCountView.backgroundColor = ColorCollection.Cyan
            self.symbolUnreadCountView.textColor = ColorCollection.White
            self.symbolUnreadCountViewWidthConst.constant = fitSize.height > fitSize.width ? fitSize.height : fitSize.width
            self.symbolUnreadCountView.layer.cornerRadius = fitSize.height / 2
            self.symbolUnreadCountView.layer.masksToBounds = true
        } else {
            self.symbolUnreadCountView.backgroundColor = UIColor.white
            self.symbolUnreadCountViewWidthConst.constant = 5
        }

        self.contentView.layoutIfNeeded()
    }

    func getRightDateString(time: Date) -> String {
        let calender: Calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        let components: DateComponents = calender.dateComponents([.year, .day, .second], from: time, to: Date())
        if components.second! < 30 {
            return NSLocalizedString("MessageTs_Now", comment: "Timestamp for now")
        } else if components.day! < 1 {
            dateFormatter.dateFormat = "HH:mm"
        } else if components.year! < 1 {
            dateFormatter.dateFormat = "MM/dd"
        } else {
            dateFormatter.dateFormat = "yyyy/MM/dd"
        }

        return dateFormatter.string(from: time)
    }
}
