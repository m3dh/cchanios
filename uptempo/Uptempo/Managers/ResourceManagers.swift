import Foundation

class ResourceManagers {
    static let storeClient = PersistStoreClient()

    static let accountMgr = AccountManager()

    private init() {
    }
}
