import UIKit

class OperationHelper {
    static func startAsyncJobAndBlockCurrentWindow(window: UIViewController, task: @escaping ()->Void, message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor.black

        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 5, width: 50, height: 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.startAnimating();
        alertController.view.addSubview(activityIndicator)
        window.present(alertController, animated: true, completion: nil)

        print("Presented popup indicator")

        DispatchQueue.main.async(execute: {
            task() // execute the real task

            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            alertController.dismiss(animated: true, completion: nil)
        })
    }
}
