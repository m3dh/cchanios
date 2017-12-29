import UIKit

class TableViewsManager {
    static let tableViewMaxItemCount = 500

    let recentSessionsTable = UITableView()
    let channelSessionsTable = UITableView()
    let directSessionsTable = UITableView()

    let recentSessionsSource = MainSessionDataSource()
    let channelSessionsSource = MainSessionDataSource()
    let directSessionsSource = MainSessionDataSource()

    let tables: [UITableView]

    init() {
        self.tables = [self.recentSessionsTable, self.channelSessionsTable, self.directSessionsTable]
        self.recentSessionsTable.translatesAutoresizingMaskIntoConstraints = false
        self.recentSessionsTable.dataSource = self.recentSessionsSource
        self.recentSessionsTable.delegate = self.recentSessionsSource
        self.recentSessionsTable.register(MainSessionCell.self, forCellReuseIdentifier: MainSessionDataSource.CellReuseIdentifier)

        self.channelSessionsTable.translatesAutoresizingMaskIntoConstraints = false
        self.channelSessionsTable.dataSource = self.channelSessionsSource
        self.channelSessionsTable.delegate = self.channelSessionsSource
        self.channelSessionsTable.register(MainSessionCell.self, forCellReuseIdentifier: MainSessionDataSource.CellReuseIdentifier)

        self.directSessionsTable.translatesAutoresizingMaskIntoConstraints = false
        self.directSessionsTable.dataSource = self.directSessionsSource
        self.directSessionsTable.delegate = self.directSessionsSource
        self.directSessionsTable.register(MainSessionCell.self, forCellReuseIdentifier: MainSessionDataSource.CellReuseIdentifier)

        self.fillInitialData()
    }

    func fillInitialData() {

    }
}
