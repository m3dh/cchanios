import UIKit

class MainSessionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    static let DataSourceUsSessions = 0
    static let DataSourceMeSessions = 1

    static let CellReuseIdentifier = "mainSessionCell"

    let dataSourceType: Int

    init(_ dataSourceType: Int) {
        self.dataSourceType = dataSourceType
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainSessionDataSource.CellReuseIdentifier, for: indexPath) as UITableViewCell
        return cell
    }
}
