import UIKit

class MainSessionCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.default

        let contentLabel = UILabel()
        self.contentView.addSubview(contentLabel)
        contentLabel.frame = self.contentView.bounds
        contentLabel.text = "content label"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
