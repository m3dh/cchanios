import UIKit

class SearchResultTableViewCell : UITableViewCell {
    var initialized = false
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var registeredAtLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!

    func load(account: UserAccount) {
        if !self.initialized {
            let imageHeight = self.avatarImageView.bounds.height
            self.avatarImageView!.layer.cornerRadius = imageHeight / 2
            self.avatarImageView!.layer.masksToBounds = true
            self.avatarImageView!.layer.borderWidth = 2
            self.avatarImageView!.layer.borderColor = ColorCollection.UserAvatarBorder0.cgColor
            self.initialized = true

            self.registeredAtLabel.textColor = ColorCollection.TableViewTimestamp
        }

        self.avatarImageView!.image = UIImage(data: account.avatarImageData!)
        self.userNameLabel.text = "\(UIControlHelper.removeTypePartFromId(id: account.accountId))"
        self.displayNameLabel.text = account.displayName

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let timeStr = dateFormatter.string(from: account.createdAt)
        self.registeredAtLabel.text = "\(timeStr)"
    }
}

class FindUserOrGroupViewController:
    UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate,
UITableViewDataSource, UITableViewDelegate {
    static let SearchResultViewCellIdentifier = "SearchResultCell"
    static let SearchResultTableRowHeight = 60

    // Nested elements
    var searchController: UISearchController!
    @IBOutlet weak var searchResultTable: UITableView!
    @IBOutlet weak var baseView: UIView!

    // Backwards
    var createSessionController: CreateSessionMenuViewController!

    var searchedUserAccounts: [UserAccount]! = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set search controller
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self
        self.searchController.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search by user or group name..."
        self.searchController.searchBar.autocapitalizationType = .none

        self.navigationItem.title = nil
        self.navigationItem.titleView = searchController.searchBar

        self.searchResultTable.delegate = self
        self.searchResultTable.dataSource = self
        self.searchResultTable.backgroundColor = UIColor(white: 0.98, alpha: 1)
        self.searchResultTable.separatorColor = UIColor(white: 0.95, alpha: 1)
        self.searchResultTable.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.isActive = true
        UIControlHelper.delayAndDo(delay: 0.1) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }

    func popBackToChatView() {
        self.dismiss(animated: true, completion: nil)
        self.createSessionController.dismissToMainAndIntoChat()
    }

    //MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        // Nothing to do for realtime client side updates...
    }

    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // For test: fill-in fake data
        let firstAccount = UserAccount()
        firstAccount.avatarImageData = UIImageJPEGRepresentation(UIImage(named: "AppIcon")!, 1)!
        firstAccount.accountId = "UA:account1"
        firstAccount.displayName = "Account Name"
        firstAccount.createdAt = Date()

        let secondAccount = UserAccount()
        secondAccount.avatarImageData = UIImageJPEGRepresentation(UIImage(named: "Avatar - Default")!, 1)!
        secondAccount.accountId = "UA:account2"
        secondAccount.displayName = "😍😍😍"
        firstAccount.createdAt = Date(timeIntervalSinceNow: -10000)

        self.searchedUserAccounts = [
            firstAccount,
            secondAccount
        ]
        self.searchResultTable.reloadData()
    }

    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(FindUserOrGroupViewController.SearchResultTableRowHeight)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        let userAccountSection = self.searchedUserAccounts.count > 0 ? 1 : 0
        let groupSection = 0

        let allSections = userAccountSection + groupSection
        if allSections == 0 {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height))
            noDataLabel.text = "No result available"
            noDataLabel.textColor = .black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }

        return allSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.searchedUserAccounts.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Create channel
        // Dismiss back and jump into chat view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FindUserOrGroupViewController.SearchResultViewCellIdentifier, for: indexPath)
        if let resultCell = cell as? SearchResultTableViewCell {
            var accountRow: UserAccount!
            if indexPath.section == 0 {
                accountRow = self.searchedUserAccounts[indexPath.row]
            } else if indexPath.section == 1 {
                // TODO: Complete this when group is developed
                fatalError("Group accounts not supported yet.")
            }

            resultCell.load(account: accountRow)
            return resultCell
        } else {
            return cell
        }
    }
}
