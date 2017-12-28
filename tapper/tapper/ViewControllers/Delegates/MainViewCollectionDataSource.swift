import UIKit

class MainViewCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let CollectionCellId = "mainViewCollectionCellId"
    let parentView: UICollectionView
    let menuBar: MainMenuBarDataSource

    init(parentView: UICollectionView, menuBar: MainMenuBarDataSource) {
        self.parentView = parentView
        self.menuBar = menuBar
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainViewCollectionDataSource.CollectionCellId, for: indexPath)
        let colors: [UIColor] = [UIColor.white, UIColor.lightGray, UIColor.darkGray]
        cell.backgroundColor = colors[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.parentView.bounds.width, height: self.parentView.bounds.height)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let movedCount = scrollView.contentOffset.x / self.parentView.frame.width
        self.menuBar.horizontalBarLeftAnchorConstraint.constant = 5 + (self.parentView.frame.width - 10) * movedCount / 3
    }
//
//    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//        let index = targetContentOffset.memory.x / view.frame.width
//
//        let indexPath = NSIndexPath(forItem: Int(index), inSection: 0)
//        menuBar.collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
//
//    }
}
