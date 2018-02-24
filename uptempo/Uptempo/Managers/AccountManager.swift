import Alamofire
import Foundation
import RealmSwift

class AccountManager {
    private let mainStore: Realm
    private let backendUrl: URL

    init(_ mainStore: Realm, _ backendServiceUrl: URL) {
        self.mainStore = mainStore
        self.backendUrl = backendServiceUrl
    }

    func getMainAccounts() -> [MainAccount] {
        return Array(self.mainStore.objects(MainAccount.self))
    }

    func getActiveMainAccount() -> MainAccount? {
        for mainAccount in self.getMainAccounts() {
            if mainAccount.authToken != nil {
                return mainAccount
            }
        }

        return nil
    }

    func createMainAccount(accountName: String, displayName: String, completion: @escaping (MainAccount) -> Void, handler: WebErrorHandler) {
        let accountPostUrl = URL(string: "api/accounts/users", relativeTo: self.backendUrl)!
        let params: Parameters = [ "account_name": accountName, "display_name": displayName ]
        Alamofire
            .request(accountPostUrl, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    let account = MainAccount()
                    account.accountId = resp["account_id"] as! String
                    account.displayName = resp["display_name"] as! String
                    account.createdAt = WebHelper.parseJsonDateString(date: resp["created_at"] as? String)!
                    completion(account)
                })
        }
    }

    func logonMainAccount() {

    }

    func setMainAccountPassword() {

    }

    func setMainAccount() {

    }

    func getOneAccount(latest: Bool) -> UserAccount {
        return UserAccount()
    }
}
