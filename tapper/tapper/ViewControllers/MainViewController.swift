import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var subNavBarView: UIView!
    @IBOutlet weak var subNavBarBottonShadowView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var menuBarCollectionView: UICollectionView!

    let usLeftTableView = UITableView()
    let meRightTableView = UITableView()

    let usSessionsSource = MainSessionDataSource(MainSessionDataSource.DataSourceUsSessions)
    let meSessionsSource = MainSessionDataSource(MainSessionDataSource.DataSourceMeSessions)

    var menuBarCollectionViewSource: MainMenuBarDataSource!
    var mainCollectionViewSource: MainViewCollectionDataSource!

    override func viewWillAppear(_ animated: Bool) {
        UIControlHelper.findAndHideShadowView(under: self.navigationController!.navigationBar, hide: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        UIControlHelper.findAndHideShadowView(under: self.navigationController!.navigationBar, hide: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if false /* no token found or auth failed */ {
            self.performSegue(withIdentifier: "mainNeedSignIn", sender: nil)
        }

        // ui views initialization
        self.subNavBarBottonShadowView.backgroundColor = UIColor.darkGray
        self.subNavBarBottonShadowView.alpha = 0.5

        // initialize two session table views.
        self.usLeftTableView.dataSource = self.usSessionsSource
        self.usLeftTableView.delegate = self.usSessionsSource
        self.usLeftTableView.register(MainSessionCell.self, forCellReuseIdentifier: MainSessionDataSource.CellReuseIdentifier)
        self.meRightTableView.dataSource = self.meSessionsSource
        self.meRightTableView.delegate = self.meSessionsSource
        self.meRightTableView.register(MainSessionCell.self, forCellReuseIdentifier: MainSessionDataSource.CellReuseIdentifier)
        self.usLeftTableView.translatesAutoresizingMaskIntoConstraints = false
        self.meRightTableView.translatesAutoresizingMaskIntoConstraints = false

        // initialize top menu bar
        self.menuBarCollectionView.register(MainMenuBarCell.self, forCellWithReuseIdentifier: MainMenuBarDataSource.CollectionCellId)
        self.menuBarCollectionViewSource = MainMenuBarDataSource(containerView: self.subNavBarView, parentView: self.menuBarCollectionView, controllingView: self.mainCollectionView)
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
        self.mainCollectionViewSource = MainViewCollectionDataSource(parentView: self.mainCollectionView, menuBar: self.menuBarCollectionViewSource)
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
    }

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let index = IndexPath(row: sender.selectedSegmentIndex, section: 0)
        self.mainCollectionView.scrollToItem(at: index, at: .left, animated: true)
    }
}
