import UIKit

class MainMenuBarDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let CollectionCellId = "menuBarCollectionCellId"
    let expectedCellCount = 3
    let parentView: UICollectionView
    let controllingView: UICollectionView
    let containerView: UIView

    var horizontalBarLeftAnchorConstraint: NSLayoutConstraint!

    init(containerView: UIView, parentView: UICollectionView, controllingView: UICollectionView) {
        self.parentView = parentView
        self.containerView = containerView
        self.controllingView = controllingView

        // initialize horizontal bar
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = UIColor.black
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(horizontalBarView)

        self.horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: 5)
        self.horizontalBarLeftAnchorConstraint.isActive = true

        horizontalBarView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor).isActive = true
        horizontalBarView.widthAnchor.constraint(equalTo: self.parentView.widthAnchor, multiplier: 1.0/CGFloat(expectedCellCount)).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.parentView.bounds.width / CGFloat(self.expectedCellCount), height: self.parentView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.expectedCellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainMenuBarDataSource.CollectionCellId, for: indexPath)
        if let menuBarCell = cell as? MainMenuBarCell {
            switch indexPath.row {
            case 0:
                menuBarCell.contentLabel.text = "Recent"
            case 1:
                menuBarCell.contentLabel.text = "Channel"
            case 2:
                menuBarCell.contentLabel.text = "Direct"
            default:
                fatalError("Not yet implemented for row \(indexPath.row)")
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = IndexPath(item: indexPath.item, section: 0)
        self.controllingView.scrollToItem(at: index, at: .left, animated: true)
    }
}

class MainMenuBarCell: UICollectionViewCell {
    let contentLabel = UILabel()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.addSubview(contentLabel)
        self.contentLabel.frame = self.contentView.bounds
        self.contentLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: 14)
        self.contentLabel.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(contentLabel)
        self.contentLabel.frame = self.contentView.bounds
        self.contentLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: 14)
        self.contentLabel.textAlignment = .center
    }

    override var isSelected: Bool{
        didSet {
            print("\(self.contentLabel.text!) is selected")
        }
    }
}
