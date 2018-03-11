import Foundation
import RealmSwift

class ChatMessage : Object {
    @objc dynamic var sentAt: Date = Date()
    @objc dynamic var messageBody: String = ""
    @objc dynamic var ordinalNumber: Int = 0
    @objc dynamic var senderAccountId: String = ""
    @objc dynamic var uuid: String = ""
}
