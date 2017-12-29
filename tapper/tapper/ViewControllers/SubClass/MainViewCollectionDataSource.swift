import UIKit

class MainViewCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let CollectionCellId = "mainViewCollectionCellId"
    let parentView: UICollectionView
    let menuBar: MainMenuBarDataSource
    let tableMgr: TableViewsManager

    init(parentView: UICollectionView, menuBar: MainMenuBarDataSource, tableViewsMgr: TableViewsManager) {
        self.parentView = parentView
        self.menuBar = menuBar
        self.tableMgr = tableViewsMgr
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainViewCollectionDataSource.CollectionCellId, for: indexPath)
        let tableView = self.tableMgr.tables[indexPath.item]
        cell.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.parentView.bounds.width, height: self.parentView.bounds.height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let movedCount = scrollView.contentOffset.x / self.parentView.frame.width
        self.menuBar.horizontalBarLeftAnchorConstraint.constant = 5 + (self.parentView.frame.width - 10) * movedCount / 3
    }

    var focusedIndex: Int {
        get {
            return Int(self.parentView.contentOffset.x / self.parentView.frame.width)
        }
    }
}
