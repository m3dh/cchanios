import UIKit

class MainSessionCell: UITableViewCell {
    var avatarImageView: UIImageView!
    var titleTextView: UILabel!

    func load(avatar: UIImage, titleText: String, msgText: String, unreadCount: Int, lastMsgTime: Date) {
        let cellHeight = self.contentView.bounds.height

        // avatar view
        self.avatarImageView = UIImageView(image: avatar)
        self.contentView.addSubview(self.avatarImageView)
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.heightAnchor.constraint(equalToConstant: cellHeight * 0.86).isActive = true
        self.avatarImageView.widthAnchor.constraint(equalToConstant: cellHeight * 0.86).isActive = true
        self.avatarImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: cellHeight*0.07).isActive = true
        self.avatarImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 10).isActive = true
        self.avatarImageView.layer.cornerRadius = cellHeight * 0.86 / 2
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.borderWidth = 1
        self.avatarImageView.layer.borderColor = UIColor.lightGray.cgColor

        // title text
        let remainingWidth = self.contentView.bounds.width - 10 - cellHeight * 0.86

        self.titleTextView = UILabel()
        self.contentView.addSubview(self.titleTextView)
        self.titleTextView.translatesAutoresizingMaskIntoConstraints = false
        self.titleTextView.leftAnchor.constraint(equalTo: self.avatarImageView.rightAnchor, constant: 0).isActive = true
        self.titleTextView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0).isActive = true
        self.titleTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 2).isActive = true
        self.titleTextView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        self.titleTextView.text = titleText
    }
}
