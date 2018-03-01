import UIKit

class AccountSettingMenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let dismissButton = UIButton()
        self.view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        dismissButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: (1.0 - SideMenuHelper.menuWidthPercent) * self.view.bounds.width).isActive = true
        dismissButton.addTarget(self, action: #selector(self.dismissToMain), for: .touchUpInside)
    }

    @objc func dismissToMain() {
        self.dismiss(animated: true, completion: nil)
    }
}
