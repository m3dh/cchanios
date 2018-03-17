import UIKit

class ShadowAvatarView : UIView {
    var avatarImage: UIImage? = nil {
        didSet {
            self.imageView.image = self.avatarImage
        }
    }

    var borderColor: CGColor? = nil {
        didSet {
            self.imageView.layer.borderColor = self.borderColor
        }
    }

    var imageView: UIImageView!

    func setNonInteractivable() {
        self.isUserInteractionEnabled = false
        self.imageView.isUserInteractionEnabled = false
        self.isExclusiveTouch = false
        self.imageView.isExclusiveTouch = false
    }

    func initialize(size: CGFloat, shadowPercent: Float) {
        self.layer.cornerRadius = size / 2
        self.layer.shadowOpacity = 0.3 * shadowPercent
        self.layer.shadowRadius = CGFloat(1.0 * shadowPercent)
        self.layer.shadowOffset = CGSize(width: CGFloat(0.5 * shadowPercent), height: CGFloat(2 * shadowPercent))
        self.layer.shadowColor = UIColor.black.cgColor

        self.imageView = UIImageView(frame: self.frame)
        self.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.imageView.layer.cornerRadius = size / 2
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderWidth = size / 20
    }
}
