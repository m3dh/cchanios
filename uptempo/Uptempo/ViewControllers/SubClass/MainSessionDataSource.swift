import UIKit

class MainSessionDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    static let CellReuseIdentifier = "mainSessionCell"

    let rowHeight: CGFloat
    let mainViewController: MainViewController

    init(rowHeight: CGFloat, mainViewController: MainViewController) {
        self.rowHeight = rowHeight
        self.mainViewController = mainViewController
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.mainViewController.performSegue(withIdentifier: "intoChatView", sender: nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainSessionDataSource.CellReuseIdentifier, for: indexPath) as UITableViewCell
        if let mainSessionCell = cell as? MainSessionCell {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

            if indexPath.row == 0 {
                mainSessionCell.load(
                    avatar: UIImage(named: "AppIcon")!,
                    titleText: "User Name 01",
                    msgText: "一汽-大众新款高尔夫家族正式上市，作为七代高尔夫的中期改款车型，它被大家戏称为7.5代高尔夫。值得一提的是，2015年刚刚推出的GTI车型也随着本次改款推出了全新车型，23.99万的官方指导价与老款保持一致，只不过在这个价格区间恰好与它的同胞兄弟，同样来自广东佛山工厂的奥迪A3 40TFSI相互重叠。",
                    unreadCount: 1,
                    lastMsgTime: Date())
            } else if indexPath.row == 1 {
                mainSessionCell.load(
                    avatar: UIImage(named: "Avatar - Default")!,
                    titleText: "ABCDE12345abcde 🚧",
                    msgText: "❤ Test message text",
                    unreadCount: 3,
                    lastMsgTime: dateFormatter.date(from: "2016-09-21 10:07")!)
            } else {
                mainSessionCell.load(
                    avatar: UIImage(named: "Avatar - Default")!,
                    titleText: "Some User Pro",
                    msgText: "In publishing and graphic design, lorem ipsum is a filler text or greeking commonly used to demonstrate the textual elements of a graphic document or visual presentation. Replacing meaningful content with placeholder text allows designers to design the form of the content before the content itself has been produced.",
                    unreadCount: 0,
                    lastMsgTime: dateFormatter.date(from: "2017-04-13 21:15")!)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return self.rowHeight;
    }
}
