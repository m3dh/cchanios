import UIKit

class CreateSessionMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    static let CellReuseIdentifier = "CreateSessionMenuTableCells"

    let menuTableView = UITableView()
    var menuItemDict: [String:[MenuTableViewCellModel]]!
    var menuItemKeys: [String]!

    var mainViewController: MainViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuItemDict = [
            "Talk to User or Group":[ MenuTableViewCellModel(title: "Search...", method: {(indexPath) in
                self.performSegue(withIdentifier: "searchUserSegue", sender: nil)
            }) ]
        ]
        self.menuItemKeys = Array(self.menuItemDict.keys)

        let dismissButton = UIButton()
        self.view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        dismissButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        dismissButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: (1.0 - SideMenuHelper.menuWidthPercent) * self.view.bounds.width).isActive = true
        dismissButton.addTarget(self, action: #selector(self.dismissToMain), for: .touchUpInside)

        self.view.addSubview(self.menuTableView)
        self.menuTableView.translatesAutoresizingMaskIntoConstraints = false
        self.menuTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.menuTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.menuTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.menuTableView.widthAnchor.constraint(equalToConstant: SideMenuHelper.menuWidthPercent * self.view.bounds.width).isActive = true
        self.menuTableView.register(MenuTableViewCell.self, forCellReuseIdentifier: CreateSessionMenuViewController.CellReuseIdentifier)
        self.menuTableView.dataSource = self
        self.menuTableView.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNav = segue.destination as? UINavigationController {
            if let destinationFinder = destinationNav.viewControllers[0] as? FindUserOrGroupViewController {
                destinationFinder.createSessionController = self
            }
        }
    }

    func dismissToMainAndIntoChat() {
        self.dismiss(animated: true, completion: nil)
        self.mainViewController.performSegue(withIdentifier: "intoChatView", sender: nil)
    }

    @objc func dismissToMain() {
        self.dismiss(animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.menuItemDict.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.menuItemKeys[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItemDict[self.menuItemKeys[section]]!.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionName = self.menuItemKeys[indexPath.section]
        let section = self.menuItemDict[sectionName]
        let item = section![indexPath.row]
        item.method(indexPath)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionName = self.menuItemKeys[indexPath.section]
        let section = self.menuItemDict[sectionName]
        let item = section![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CreateSessionMenuViewController.CellReuseIdentifier, for: indexPath)
        if let menuCell = cell as? MenuTableViewCell {
            self.setMenuCell(cell: menuCell, title: item.title)
        }

        return cell
    }

    func setMenuCell(cell: MenuTableViewCell, title: String) {
        if cell.cellTitleLabel == nil {
            cell.cellTitleLabel = UILabel()
            cell.contentView.addSubview(cell.cellTitleLabel!)
            cell.cellTitleLabel!.translatesAutoresizingMaskIntoConstraints = false
            cell.cellTitleLabel!.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor).isActive = true
            cell.cellTitleLabel!.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true

            cell.cellTitleLabel!.font = UIFont.init(name: "AvenirNext-DemiBold", size: 14)
            cell.cellTitleLabel!.textColor = ColorCollection.NavigationBarUnselectedTextColor
            cell.cellTitleLabel!.textAlignment = .center
        }

        cell.cellTitleLabel!.text = title
    }
}
