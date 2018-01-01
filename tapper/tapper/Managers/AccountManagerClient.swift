import Foundation
import Alamofire

class AccountManagerClient {
    let url: URL

    init(_ baseUrl: String) {
        self.url = URL(string: baseUrl)!
    }

    func createAccountAvatar(image: UIImage) -> String {
        return ""
    }
}
