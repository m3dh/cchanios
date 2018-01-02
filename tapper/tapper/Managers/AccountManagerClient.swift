import Foundation
import Alamofire

class AccountManagerClient {
    let url: URL

    init(_ baseUrl: String) {
        self.url = URL(string: baseUrl)!
    }

    func retrieveAccountAvatar(uuid: String, completion: @escaping (Data) -> Void, failure: @escaping (String) -> Void) {
        let avatarGetUrl = URL(string: "/images/avatars/\(uuid)", relativeTo: self.url)!
        Alamofire
            .request(avatarGetUrl)
            .responseData { response -> Void in
                let (fail, msg) = WebHelper.tryGetWebErrorMessageFrom(response: response)
                guard !fail else {
                    failure(msg)
                    return
                }

                if let result = response.result.value {
                    completion(result)
                } else {
                    failure("Unexpected response from server")
                }
            }
    }

    func createAccountAvatar(image: Data, completion: @escaping (String) -> Void,  failure: @escaping (String) -> Void) {
        let avatarPostUrl = URL(string: "/images/avatars", relativeTo: self.url)!
        Alamofire
            .upload(image, to: avatarPostUrl, method: .post)
            .responseJSON { response -> Void in
                let (fail, msg) = WebHelper.tryGetWebErrorMessageFrom(response: response)
                guard !fail else {
                    failure(msg)
                    return
                }

                if let result = response.result.value {
                    let resultDict = result as! [String:String]
                    if let uuid = resultDict["UUID"] {
                        completion(uuid)
                    } else {
                        failure("Unexpected response from server : ID not found.")
                    }
                } else {
                    failure("Unexpected response from server")
                }
        }
    }
}
