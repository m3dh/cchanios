import UIKit

class FindUserOrGroupViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBAction func navigationCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        self.navigationBar.topItem?.title = "Create Session"
    }
}
