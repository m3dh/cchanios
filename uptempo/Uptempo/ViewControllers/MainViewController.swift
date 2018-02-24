import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var subNavBarView: UIView!
    @IBOutlet weak var subNavBarBottonShadowView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var menuBarCollectionView: UICollectionView!

    var menuBarCollectionViewSource: MainMenuBarDataSource!
    var mainCollectionViewSource: MainViewCollectionDataSource!
    var tableViewsManager: TableViewsManager!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIControlHelper.findAndHideShadowView(under: self.navigationController!.navigationBar, hide: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIControlHelper.findAndHideShadowView(under: self.navigationController!.navigationBar, hide: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if ResourceManager.accountMgr.getActiveMainAccount() == nil {
            self.performSegue(withIdentifier: "mainNeedSignIn", sender: nil)
        }

        // ui views initialization
        self.subNavBarView.backgroundColor = ColorCollection.NavigationBarBackgroundColor
        self.subNavBarBottonShadowView.backgroundColor = UIColor.darkGray
        self.subNavBarBottonShadowView.alpha = 0.5
  
        // initialize top menu bar
        self.menuBarCollectionView.register(MainMenuBarCell.self, forCellWithReuseIdentifier: MainMenuBarDataSource.CollectionCellId)
        self.menuBarCollectionViewSource = MainMenuBarDataSource(containerView: self.subNavBarView, parentView: self.menuBarCollectionView, controllingView: self.mainCollectionView, screenWidth: self.view.frame.width)
        self.menuBarCollectionView.delegate = self.menuBarCollectionViewSource
        self.menuBarCollectionView.dataSource = self.menuBarCollectionViewSource
        self.menuBarCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.menuBarCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.menuBarCollectionView.isPagingEnabled = true
        self.menuBarCollectionView.backgroundColor = self.navigationController!.navigationBar.barTintColor
        if let flowLayout = self.menuBarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }

        // background collection view
        self.tableViewsManager = TableViewsManager()
        self.mainCollectionViewSource = MainViewCollectionDataSource(parentView: self.mainCollectionView, menuBar: self.menuBarCollectionViewSource, menuBarView: self.menuBarCollectionView, tableViewsMgr: tableViewsManager)
        self.mainCollectionView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        self.mainCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: MainViewCollectionDataSource.CollectionCellId)
        self.mainCollectionView.delegate = self.mainCollectionViewSource
        self.mainCollectionView.dataSource = self.mainCollectionViewSource
        self.mainCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.mainCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.mainCollectionView.isPagingEnabled = true
        if let flowLayout = self.mainCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }

        // trigger data reload
        self.menuBarCollectionView.reloadData()
        self.mainCollectionView.reloadData()

        self.menuBarCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
    }

    @IBAction func unwindToMainView(sender: UIStoryboardSegue) {
    }
}
