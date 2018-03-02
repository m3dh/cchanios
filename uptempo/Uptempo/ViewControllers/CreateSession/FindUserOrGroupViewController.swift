import UIKit

class FindUserOrGroupViewController: UIViewController {
    @IBAction func navigationCancel(_ sender: Any)  {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func navigationTest(_ sender: Any) {
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        self.navigationController?.pushViewController(mainViewController!, animated: true)
    }

    override func viewDidLoad() {
        self.navigationItem.title = "Find user"
    }
}
