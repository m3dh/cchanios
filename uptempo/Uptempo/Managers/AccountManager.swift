import Alamofire
import Foundation
import RealmSwift

// There's no primary key, no index for the main account: there should be only one main account.
class MainAccount : Object {
    @objc dynamic var accountId: String = ""
    @objc dynamic var accountUserName: String = ""
    @objc dynamic var displayName: String = ""
    @objc dynamic var createdAt: Date = Date()

    @objc dynamic var avatarImageId: String? = nil
    @objc dynamic var avatarImageData: Data? = nil

    @objc dynamic var authToken: String? = nil
    let authDeviceId = RealmOptional<Int>()

    override static func primaryKey() -> String? {
        return "accountId"
    }
}

class UserAccount : Object {
    @objc dynamic var accountId: String = ""
    @objc dynamic var displayName: String = ""
    @objc dynamic var createdAt: Date = Date()

    @objc dynamic var avatarImageId: String? = nil // Core image ID
    @objc dynamic var avatarImageData: Data? = nil

    override static func primaryKey() -> String? {
        return "accountId"
    }
}

class AuthTokenViewObject {
    var token: String = ""
    var deviceId: Int = -1
    var expire: Date = Date()
}

class AccountManager {
    private let mainStore: Realm
    private let backendUrl: URL

    init(_ mainStore: Realm, _ backendServiceUrl: URL) {
        self.mainStore = mainStore
        self.backendUrl = backendServiceUrl
    }

    //MARK: Storage methods
    func getStoreMainAccounts() -> [MainAccount] {
        return Array(self.mainStore.objects(MainAccount.self))
    }

    func getStoreMainAccount(username: String) -> MainAccount? {
        for mainAccount in self.getStoreMainAccounts() {
            if mainAccount.accountUserName.compare(username) == ComparisonResult.orderedSame {
                return mainAccount
            }
        }

        return nil
    }

    func getStoreActiveMainAccount() -> MainAccount? {
        let accounts = self.getStoreMainAccounts()
        for mainAccount in accounts {
            if mainAccount.authToken != nil {
                return mainAccount
            }
        }

        return accounts.first
    }

    func createStoreMainAccount(accountId: String, username: String, createdAt: Date, authDeviceId: Int?, authToken: String?) {
        let mainAccount = MainAccount()
        mainAccount.accountId = accountId
        mainAccount.accountUserName = username
        mainAccount.createdAt = createdAt
        mainAccount.authDeviceId.value = authDeviceId
        mainAccount.authToken = authToken
        try! self.mainStore.write {
            self.mainStore.add(mainAccount)
        }
    }

    func setStoreMainAccountAuthInfo(account: MainAccount, authToken: String, authDeviceId: Int) {
        try! self.mainStore.write {
            account.setValue(authToken, forKey: "authToken")
            account.setValue(authDeviceId, forKey: "authDeviceId")
        }
    }

    func setStoreMainAccountAvatar(account: MainAccount, imageId: String, imageData: Data) {
        try! self.mainStore.write {
            account.setValue(imageId, forKey: "avatarImageId")
            account.setValue(imageData, forKey: "avatarImageData")
        }
    }

    func resetStoreMainAccountAuthInfo(account: MainAccount) {
        try! self.mainStore.write {
            account.setValue(nil, forKey: "authToken")
        }
    }

    //MARK: User account web APIs
    func getUserAccount(accountName: String, completion: @escaping (UserAccount) -> Void, handler: WebErrorHandler) {
        let accountGetUrl = URL(string: "api/accounts/users/\(accountName)", relativeTo: self.backendUrl)!
        Alamofire
            .request(accountGetUrl, method: .get, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    let account = UserAccount()
                    account.accountId = WebHelper.getResponseField(resp["account_id"] as? String)
                    account.displayName = WebHelper.getResponseField(resp["display_name"] as? String)
                    account.avatarImageId = resp["avatar_image_id"] as? String
                    account.createdAt = WebHelper.getResponseField(WebHelper.parseJsonDateString(date: resp["created_at"] as? String))
                    completion(account)
                })
        }
    }

    //MARK: Main account web APIs
    func createMainAccount(accountName: String, displayName: String, completion: @escaping (MainAccount) -> Void, handler: WebErrorHandler) {
        let accountPostUrl = URL(string: "api/accounts/users", relativeTo: self.backendUrl)!
        let params: Parameters = [ "account_name": accountName, "display_name": displayName ]
        Alamofire
            .request(accountPostUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    let account = MainAccount()
                    account.accountId = WebHelper.getResponseField(resp["account_id"] as? String)
                    account.displayName = WebHelper.getResponseField(resp["display_name"] as? String)
                    account.createdAt = WebHelper.getResponseField(WebHelper.parseJsonDateString(date: resp["created_at"] as? String))
                    completion(account)
                })
        }
    }

    func updateMainAccount(mainAccount: MainAccount, displayName: String?, avatarImageId: String?, completion: @escaping (MainAccount) -> Void, handler: WebErrorHandler) {
        let accountPatchUrl = URL(string: "api/accounts/users/\(mainAccount.accountId)", relativeTo: self.backendUrl)!
        var params: Parameters = [:]
        if let displayNameObj = displayName {
            params["display_name"] = displayNameObj
        }

        if let avatarImageIdObj = avatarImageId {
            params["avatar_image_id"] = avatarImageIdObj
        }

        Alamofire
            .request(accountPatchUrl, method: .patch, parameters: params, encoding: JSONEncoding.default, headers: WebHelper.getAuthHeader(account: mainAccount))
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    let account = MainAccount()
                    account.accountId = WebHelper.getResponseField(resp["account_id"] as? String)
                    account.displayName = WebHelper.getResponseField(resp["display_name"] as? String)
                    account.createdAt = WebHelper.getResponseField(WebHelper.parseJsonDateString(date: resp["created_at"] as? String))
                    account.avatarImageId = resp["avatar_image_id"] as? String
                    completion(account)
                })
        }
    }

    func logonMainAccount(accountName: String, passwordHash: String, deviceId: Int?, completion: @escaping (AuthTokenViewObject) -> Void, handler: WebErrorHandler) {
        var accountPostTokenUrl: URL
        if let authDeviceId = deviceId {
            accountPostTokenUrl = URL(string: "api/accounts/users/\(accountName)/tokens?device_id=\(authDeviceId)", relativeTo: self.backendUrl)!
        }
        else {
            accountPostTokenUrl = URL(string: "api/accounts/users/\(accountName)/tokens", relativeTo: self.backendUrl)!
        }

        let params: Parameters = [ "password": passwordHash ]
        Alamofire
            .request(accountPostTokenUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    let authToken = AuthTokenViewObject()
                    authToken.token = WebHelper.getResponseField(resp["token"] as? String)
                    authToken.deviceId = WebHelper.getResponseField(resp["device_id"] as? Int)
                    authToken.expire = WebHelper.getResponseField(WebHelper.parseJsonDateString(date: resp["expire"] as? String))
                    completion(authToken)
                })
        }
    }

    func setMainAccountPassword(accountName: String, passwordHash: String, completion: @escaping (MainAccount) -> Void, handler: WebErrorHandler) {
        let accountPasswordPostUrl = URL(string: "api/accounts/users/\(accountName)/password", relativeTo: self.backendUrl)!
        let params: Parameters = [ "password": passwordHash ]
        Alamofire
            .request(accountPasswordPostUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    let account = MainAccount()
                    account.accountId = WebHelper.getResponseField(resp["account_id"] as? String)
                    account.displayName = WebHelper.getResponseField(resp["display_name"] as? String)
                    account.createdAt = WebHelper.getResponseField(WebHelper.parseJsonDateString(date: resp["created_at"] as? String))
                    completion(account)
                })
        }
    }
}
