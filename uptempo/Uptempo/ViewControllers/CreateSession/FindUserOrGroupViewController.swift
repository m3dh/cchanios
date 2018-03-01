import UIKit

class FindUserOrGroupViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!

    @IBAction func navigationCancelAction(_ sender: Any) {
        let controllers = self.navigationController!.viewControllers
        for controller in controllers {
            if let c = controller as? MainViewController {
                self.navigationController!.popToViewController(c, animated: true)
                // c.unwindFromSignUpViewController(sourceViewController: self)
            }}
    }

    override func viewDidLoad() {
        self.navigationBar.topItem?.title = "Create Session"
    }
}
