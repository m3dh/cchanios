import Foundation
import Alamofire

class AccountResponse {
    var name: String?
    var displayName: String?
    var avatar: String?
    var createdAt: Date?

    init(_ dict: NSDictionary) {
        self.name = dict["Name"] as? String
        self.displayName = dict["DisplayName"] as? String
        self.avatar = dict["Avatar"] as? String
        let item = dict["CreatedAt"]
        print(item!)
    }
}

class AccountManagerClient {
    let url: URL

    init(_ baseUrl: String) {
        self.url = URL(string: baseUrl)!
    }

    func createUserAccount(accountName: String, displayName: String, completion: @escaping (AccountResponse) -> Void, handler: WebErrorHandler) {
        let accountPostUrl = URL(string: "/accounts", relativeTo: self.url)!
        let params: Parameters = [:]
        Alamofire
            .request(accountPostUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    completion(AccountResponse(resp)) })
        }
    }

    func retrieveAccountAvatar(uuid: String, completion: @escaping (Data) -> Void, handler: WebErrorHandler) {
        let avatarGetUrl = URL(string: "/images/avatars/\(uuid)", relativeTo: self.url)!
        Alamofire
            .request(avatarGetUrl)
            .responseData { response -> Void in WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: completion) }
    }

    func createAccountAvatar(image: Data, completion: @escaping (String) -> Void,  handler: WebErrorHandler) {
        let avatarPostUrl = URL(string: "/images/avatars", relativeTo: self.url)!
        Alamofire
            .upload(image, to: avatarPostUrl, method: .post)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    if let uuid = resp["UUID"] as? String {
                        completion(uuid)
                    } else {
                        handler.generalError(message: "Unexpected response from server : avatar not created.")
                    }
                })
        }
    }
}
