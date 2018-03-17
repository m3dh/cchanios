import UIKit

class TableViewsManager {
    static let tableViewMaxItemCount = 500

    let recentSessionsTable = UITableView()
    let channelSessionsTable = UITableView()
    let directSessionsTable = UITableView()

    let recentSessionsSource: MainSessionDataSource
    let channelSessionsSource: MainSessionDataSource
    let directSessionsSource: MainSessionDataSource

    let tables: [UITableView]

    init(mainViewController: MainViewController) {
        self.recentSessionsSource = MainSessionDataSource(rowHeight: 72, mainViewController: mainViewController)
        self.channelSessionsSource = MainSessionDataSource(rowHeight: 72, mainViewController: mainViewController)
        self.directSessionsSource = MainSessionDataSource(rowHeight: 72, mainViewController: mainViewController)

        self.tables = [self.recentSessionsTable, self.channelSessionsTable, self.directSessionsTable]
        self.recentSessionsTable.translatesAutoresizingMaskIntoConstraints = false
        self.recentSessionsTable.dataSource = self.recentSessionsSource
        self.recentSessionsTable.delegate = self.recentSessionsSource
        self.recentSessionsTable.register(MainSessionCell.self, forCellReuseIdentifier: MainSessionDataSource.CellReuseIdentifier)
        self.recentSessionsTable.separatorColor = ColorCollection.White
        self.recentSessionsTable.backgroundColor = ColorCollection.White

        self.channelSessionsTable.translatesAutoresizingMaskIntoConstraints = false
        self.channelSessionsTable.dataSource = self.channelSessionsSource
        self.channelSessionsTable.delegate = self.channelSessionsSource
        self.channelSessionsTable.register(MainSessionCell.self, forCellReuseIdentifier: MainSessionDataSource.CellReuseIdentifier)
        self.channelSessionsTable.separatorColor = ColorCollection.White
        self.channelSessionsTable.backgroundColor = ColorCollection.White

        self.directSessionsTable.translatesAutoresizingMaskIntoConstraints = false
        self.directSessionsTable.dataSource = self.directSessionsSource
        self.directSessionsTable.delegate = self.directSessionsSource
        self.directSessionsTable.register(MainSessionCell.self, forCellReuseIdentifier: MainSessionDataSource.CellReuseIdentifier)
        self.directSessionsTable.separatorColor = ColorCollection.White
        self.directSessionsTable.backgroundColor = ColorCollection.White
    }
}
