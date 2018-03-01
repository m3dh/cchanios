import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var subNavBarView: UIView!
    @IBOutlet weak var subNavBarBottonShadowView: UIView!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var menuBarCollectionView: UICollectionView!

    var menuBarCollectionViewSource: MainMenuBarDataSource!
    var mainCollectionViewSource: MainViewCollectionDataSource!
    var tableViewsManager: TableViewsManager!
    var activeMainAccount: MainAccount! // Should be read from realm DB (linked).
    var activeMainAccountAvatar: UIImage!

    var sideMenuActivatedDirection: SideMenuSlideDirection? = nil

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

        let mainAccount = ResourceManager.accountMgr.getStoreActiveMainAccount()
        if mainAccount == nil || mainAccount?.authToken == nil {
            self.performSegue(withIdentifier: "mainNeedSignIn", sender: nil)
        } else {
            self.activeMainAccount = mainAccount!
            self.activeMainAccountAvatar = UIImage(data: self.activeMainAccount.avatarImageData!)!

            let leftBarAvatarView = UIImageView(image: self.activeMainAccountAvatar)
            leftBarAvatarView.widthAnchor.constraint(equalToConstant: 35).isActive = true
            leftBarAvatarView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            leftBarAvatarView.translatesAutoresizingMaskIntoConstraints = false
            leftBarAvatarView.layer.cornerRadius = 17.0
            leftBarAvatarView.layer.masksToBounds = true
            leftBarAvatarView.layer.borderWidth = 0.7
            leftBarAvatarView.layer.borderColor = UIColor.gray.cgColor
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarAvatarView)
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

    func handleAuthenticationError() {
        
    }

    @IBAction func unwindToMainView(sender: UIStoryboardSegue) {
        self.activeMainAccount = ResourceManager.accountMgr.getStoreActiveMainAccount()!
        if self.activeMainAccount.authToken == nil {
            fatalError("Unexpected auth token status after sign-in / sign-up(s)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? CreateSessionViewController {
            self.sideMenuActivatedDirection = .Right
            dest.transitioningDelegate = self
        }
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidePresentMenuAnimator(direction: self.sideMenuActivatedDirection!)
    }
}
