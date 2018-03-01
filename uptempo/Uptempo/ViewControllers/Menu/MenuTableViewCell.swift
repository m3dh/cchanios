import UIKit

class MenuTableViewCellModel {
    let title: String
    let method: (IndexPath) -> Void

    init(title: String, method: @escaping(IndexPath)->Void) {
        self.title = title
        self.method = method
    }
}

class MenuTableViewCell: UITableViewCell {
    var cellTitleLabel: UILabel?
}
