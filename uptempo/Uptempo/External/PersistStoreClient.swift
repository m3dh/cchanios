import RealmSwift

// There's no primary key, no index for the main account: there should be only one main account.
class MainAccount : Object {
    @objc dynamic var id = 0

    @objc dynamic var name: String = ""
    @objc dynamic var displayName: String = ""
    @objc dynamic var createdAt: Date = Date()

    @objc dynamic var avatarImageId: String?
    @objc dynamic var avatarImageData: Data?
    
    @objc dynamic var authToken: String?

    override static func primaryKey() -> String? {
        return "id"
    }
}

// TODO: Consider handle realm errors?
class PersistStoreClient {
    static let mainDbFileName = "main.realm"

    let mainDb: Realm

    init() {
        // init the default DB instance, as the first Realm instance, which has tables: MainAccount(1), FilePartitionInfo(N)
        var config = Realm.Configuration(objectTypes: [MainAccount.self])
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent(PersistStoreClient.mainDbFileName)
        let realm = try! Realm(configuration: config)
        self.mainDb = realm
    }


    // There shall be only one main account, while the real databases could contains data from multiple accounts
    func getMainAccount() -> MainAccount? {
        return self.mainDb.objects(MainAccount.self).first
    }

    func putMainAccount(account: MainAccount) {
        account.id = 0
        try! self.mainDb.write {
            self.mainDb.add(account, update: true)
        }
    }

    func setMainAccount(update: (MainAccount) -> Void) {
        if let account = self.getMainAccount() {
            try! self.mainDb.write {
                update(account)
            }
        }
    }

    func delMainAccount() {
        if let account = self.getMainAccount() {
            try! self.mainDb.write {
                self.mainDb.delete(account)
            }
        }
    }
}
