import UIKit

class FindUserOrGroupViewController: UIViewController {
    var createSessionController: CreateSessionMenuViewController!

    @IBAction func navigationCancel(_ sender: Any)  {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func navigationTest(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.createSessionController.dismissToMainAndIntoChat()
    }

    override func viewDidLoad() {
        self.navigationItem.title = "Find user"
    }
}
