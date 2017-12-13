import UIKit

class SceneTableViewController: UITableViewController { // UITableViewDataSource contained
    var items = [Item]()

    override func viewDidLoad() {
        self.loadSampleData()
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

        if let image = item.photo {
            cell.hCellImage.image = image
        }

        return cell
    }

    @IBAction func unwindToSceneList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SceneViewController, let item = sourceViewController.item {
            let index = IndexPath(row: self.items.count, section: 0)
            self.items.append(item)
            self.tableView.insertRows(at: [index], with: .automatic)
        }
    }

    private func loadSampleData() {
        let item1 = Item(n: "Item-1", photo: nil, rating: 3)!
        let item2 = Item(n: "Item-2", photo: nil, rating: 5)!
        self.items += [item1, item2]
    }
}
