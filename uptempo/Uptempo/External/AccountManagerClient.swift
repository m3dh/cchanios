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
        if let dateStr = dict["CreatedAt"] as? String {
            self.createdAt = WebHelper.parseJsonDateString(date: dateStr)
        }
    }
}

class AccountTokenResponse {
    var token: String?
    var deviceId: Int?
    var serverTime: Date?

    init(_ dict: NSDictionary) {
        self.token = dict["Token"] as? String
        self.deviceId = dict["DeviceID"] as? Int
        if let serverTime = dict["ServerTime"] as? String {
            self.serverTime = WebHelper.parseJsonDateString(date: serverTime)
        }
    }
}

class AccountServiceClient {
    let url: URL

    init(_ baseUrl: String) {
        self.url = URL(string: baseUrl)!
    }

    func logonUserAccount(accountName: String, passwordB64: String, deviceId: Int?, completion: @escaping (AccountTokenResponse) -> Void, handler: WebErrorHandler) {
        var accountAuthUrl: URL
        if let deviceId = deviceId {
            accountAuthUrl = URL(string: "/accounts/\(accountName)/token?device_id=\(deviceId)", relativeTo: self.url)!
        } else {
            accountAuthUrl = URL(string: "/accounts/\(accountName)/token", relativeTo: self.url)!
        }

        let params: Parameters = [ "Name": accountName, "Password": passwordB64 ]
        Alamofire
            .request(accountAuthUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    completion(AccountTokenResponse(resp)) })
        }
    }

    func createUserAccount(accountName: String, displayName: String, completion: @escaping (AccountResponse) -> Void, handler: WebErrorHandler) {
        let accountPostUrl = URL(string: "/accounts", relativeTo: self.url)!
        let params: Parameters = [ "Name": accountName, "DisplayName": displayName ]
        Alamofire
            .request(accountPostUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    completion(AccountResponse(resp)) })
        }
    }

    func retrieveUserAccount(accountName: String, completion: @escaping (AccountResponse) -> Void, handler: WebErrorHandler) {
        let accountGetUrl = URL(string: "/accounts/\(accountName)", relativeTo: self.url)!
        Alamofire
            .request(accountGetUrl) //?
            .responseJSON { response -> Void in WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: {resp->() in completion(AccountResponse(resp)) }) }
    }

    func updateUserAccountPassword(accountName: String, passwordB64: String, completion: @escaping (AccountResponse) -> Void, handler: WebErrorHandler) {
        let accountPatchUrl = URL(string: "/accounts/\(accountName)", relativeTo: self.url)!
        let params: Parameters = [ "Name": accountName, "Password": passwordB64 ]
        Alamofire
            .request(accountPatchUrl, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: nil)
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
