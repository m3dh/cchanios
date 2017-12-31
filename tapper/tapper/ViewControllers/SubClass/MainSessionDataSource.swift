import UIKit

class MainSessionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    static let CellReuseIdentifier = "mainSessionCell"

    let rowHeight: CGFloat

    init(rowHeight: CGFloat) {
        self.rowHeight = rowHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainSessionDataSource.CellReuseIdentifier, for: indexPath) as UITableViewCell
        if let mainSessionCell = cell as? MainSessionCell {
            if indexPath.row == 0 {
                mainSessionCell.load(
                    avatar: UIImage(named: "AppIcon")!,
                    titleText: "Title Text",
                    msgText: "Test message text 01",
                    unreadCount: 1,
                    lastMsgTime: Date())
            } else {
                mainSessionCell.load(
                    avatar: UIImage(named: "Avatar - Default")!,
                    titleText: "Title Text",
                    msgText: "Test message text 02",
                    unreadCount: 3,
                    lastMsgTime: Date())
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.rowHeight;
    }
}
