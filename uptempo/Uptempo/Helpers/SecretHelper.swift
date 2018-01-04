import Foundation

class SecretHelper {
    static func fillUserAccountPassword(account: AccountResponse, password: String) -> String {
        guard let createdAt = account.createdAt else {
            fatalError("Unexpected account response : createdAt is nil")
        }
        let timeFormatter = ISO8601DateFormatter()
        let passwordAndSalt = "\(password)-\(timeFormatter.string(from: createdAt))"
        let data = passwordAndSalt.data(using: String.Encoding.utf8)!

        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }

        return Data(bytes: digest).base64EncodedString()
    }
}
