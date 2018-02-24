import Foundation
import RealmSwift

class ResourceManager {
    private static let mainDbFileName = "main.realm"

    private static let mainStore: Realm = {
        // init the default DB instance, as the first Realm instance, which has tables: MainAccount(1), FilePartitionInfo(N)
        var config = Realm.Configuration(objectTypes: [MainAccount.self])
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent(ResourceManager.mainDbFileName)
        let realm = try! Realm(configuration: config)
        return realm
    } ()

    private static let serviceBaseUrl: URL = URL(string: ResourceManager.locateBackendService())!

    static let accountMgr = AccountManager(ResourceManager.mainStore, ResourceManager.serviceBaseUrl)

    private init() {
    }

    private static func locateBackendService() -> String {
        return "http://localhost:8080"
    }
}
