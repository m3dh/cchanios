import UIKit

class FindUserOrGroupViewController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    // Nested elements
    var searchController: UISearchController!

    // Backwards
    var createSessionController: CreateSessionMenuViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        

        self.navigationItem.title = nil
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.delegate = self
        self.searchController.delegate = self
        self.navigationItem.titleView = searchController.searchBar

        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false

        self.searchController.searchBar.placeholder = "Search by user or group name..."
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
    }

    //MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

    }
}
