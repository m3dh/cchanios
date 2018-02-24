import RealmSwift

// There's no primary key, no index for the main account: there should be only one main account.
class MainAccount : Object {
    @objc dynamic var accountId: String = ""
    @objc dynamic var displayName: String = ""
    @objc dynamic var createdAt: Date = Date()

    @objc dynamic var avatarImageId: String?
    @objc dynamic var avatarImageData: Data?

    @objc dynamic var authToken: String?

    override static func primaryKey() -> String? {
        return "accountId"
    }
}

class UserAccount : Object {
}
