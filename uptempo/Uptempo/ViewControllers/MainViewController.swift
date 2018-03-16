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
            self.setMainAccount(mainAccount: mainAccount!)
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
        self.tableViewsManager = TableViewsManager(mainViewController: self)
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

    func setMainAccount(mainAccount: MainAccount) {
        self.activeMainAccount = mainAccount
        self.activeMainAccountAvatar = UIImage(data: self.activeMainAccount.avatarImageData!)!

        if self.activeMainAccount.authToken == nil {
            fatalError("Unexpected auth token status after sign-in / sign-up(s)")
        }

        let leftBarBaseButton = UIButton(type: .custom)
        leftBarBaseButton.setImage(self.activeMainAccountAvatar, for: .normal)
        leftBarBaseButton.imageView!.translatesAutoresizingMaskIntoConstraints = false
        leftBarBaseButton.translatesAutoresizingMaskIntoConstraints = false
        leftBarBaseButton.imageView!.widthAnchor.constraint(equalToConstant: 35).isActive = true
        leftBarBaseButton.imageView!.heightAnchor.constraint(equalToConstant: 35).isActive = true
        leftBarBaseButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        leftBarBaseButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        leftBarBaseButton.imageView!.layer.cornerRadius = 17.5
        leftBarBaseButton.imageView!.layer.masksToBounds = true
        leftBarBaseButton.imageView!.layer.borderWidth = 1.7
        leftBarBaseButton.imageView!.layer.borderColor = ColorCollection.UserAvatarBorder0.cgColor
        leftBarBaseButton.addTarget(self, action: #selector(self.segueToAccountSettingMenu), for: UIControlEvents.allTouchEvents)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarBaseButton)
        self.navigationItem.leftBarButtonItem!.customView!.translatesAutoresizingMaskIntoConstraints = false
        self.navigationItem.leftBarButtonItem!.customView!.widthAnchor.constraint(equalToConstant: 35).isActive = true
        self.navigationItem.leftBarButtonItem!.customView!.heightAnchor.constraint(equalToConstant: 35).isActive = true
        self.navigationItem.leftBarButtonItem!.style = .plain
        self.navigationItem.leftBarButtonItem!.isEnabled = true
    }

    @IBAction func unwindToMainView(sender: UIStoryboardSegue) {
        self.setMainAccount(mainAccount: ResourceManager.accountMgr.getStoreActiveMainAccount()!)
    }

    @objc func segueToAccountSettingMenu() {
        self.performSegue(withIdentifier: "intoAccountSetting", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? CreateSessionMenuViewController {
            self.sideMenuActivatedDirection = .Right
            dest.transitioningDelegate = self
            dest.mainViewController = self
        } else if let dest = segue.destination as? AccountSettingMenuViewController {
            self.sideMenuActivatedDirection = .Left
            dest.transitioningDelegate = self
        } else if let dest = segue.destination as? ChatViewController {
            dest.currentUserAccount = self.activeMainAccount
        }
    }
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SidePresentMenuAnimator(direction: self.sideMenuActivatedDirection!)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SideDismissMenuAnimator()
    }
}
