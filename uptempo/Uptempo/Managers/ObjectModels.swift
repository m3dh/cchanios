import RealmSwift

// There's no primary key, no index for the main account: there should be only one main account.
class MainAccount : Object {
    @objc dynamic var accountId: String = ""
    @objc dynamic var accountUserName: String = ""
    @objc dynamic var displayName: String = ""
    @objc dynamic var createdAt: Date = Date()

    @objc dynamic var avatarImageId: String?
    @objc dynamic var avatarImageData: Data?

    @objc dynamic var authToken: String?
    let authDeviceId = RealmOptional<Int>()

    override static func primaryKey() -> String? {
        return "accountId"
    }
}

class UserAccount : Object {
    @objc dynamic var accountId: String = ""
    @objc dynamic var displayName: String = ""
    @objc dynamic var createdAt: Date = Date()

    @objc dynamic var avatarImageId: String?
    @objc dynamic var avatarUrl: String?

    @objc dynamic var avatarImageData: Data?

    override static func primaryKey() -> String? {
        return "accountId"
    }
}

class AuthTokenViewObject {
    var token: String = ""
    var deviceId: Int = -1
    var expire: Date = Date()
}
