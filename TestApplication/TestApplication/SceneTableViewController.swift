import UIKit
import os.log

class SceneTableViewController: UITableViewController { // UITableViewDataSource contained
    var items = [Item]()

    override func viewDidLoad() {
        if let itemList = Item.loadItemList() {
            self.items += itemList
        } else {
            self.editButtonItem.isEnabled = false
        }

        self.navigationItem.leftBarButtonItem = editButtonItem
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let segueId = segue.identifier {
            switch(segueId) {
            case "AddItem":
                os_log("AddItem is called.", log: OSLog.default, type: .debug)
                self.tableView.setEditing(false, animated: true)

            case "ShowSceneDetail":
                os_log("ShowSceneDetail is called.", log: OSLog.default, type: .debug)
                self.tableView.setEditing(false, animated: true)
                if let targetView = segue.destination as? SceneViewController {
                    if let clickCell = sender as? ItemCell {
                        targetView.item = clickCell.item
                        targetView.isEdit = true
                    }
                }

            default:
                fatalError("Unexpected segue \(segueId)")
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ItemCells"
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        guard let cell = reusableCell as? ItemCell else {
            fatalError("The dequeued cell is not an instance of 'ItemCell'.")
        }

        let item = self.items[indexPath.row]
        cell.hCellLabel.text = item.name
        cell.hCellRatingCtrl.rating = item.rating
        cell.hCellRatingCtrl.setAllowed = false
        cell.item = item

        if let image = item.photo {
            cell.hCellImage.image = image
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            Item.saveItemList(list: self.items)
            if self.items.count == 0 {
                self.editButtonItem.isEnabled = false
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    @IBAction func unwindToSceneList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SceneViewController, let item = sourceViewController.item {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                os_log("Updating scenes list...", log: OSLog.default, type: .debug)
                self.items[selectedIndexPath.row] = item
                self.tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.right)
            } else {
                os_log("Appending scenes list...", log: OSLog.default, type: .debug)
                let index = IndexPath(row: self.items.count, section: 0)
                self.items.append(item)
                self.tableView.insertRows(at: [index], with: .automatic)
                self.editButtonItem.isEnabled = true
            }

            Item.saveItemList(list: self.items)
        }
    }
}
