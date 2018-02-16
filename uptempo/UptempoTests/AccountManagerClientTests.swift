import XCTest
import Foundation
@testable import Uptempo

class AccountServiceClientTests: XCTestCase {
    func testUploadAndDownloadAvatarImage_ShallSuccess() {
        let e = expectation(description: "ImageHelper")
        let image = UIImage(named: "Avatar - Default")!
        let client = BackendServiceLocator.instance.getAccountClient()
        let imageData = ImageHelper.compressImageToJpeg(image: image, maxSize: 64)!
        var resultUuid: String! = "empty"
        client.createAccountAvatar(image: imageData, completion:  {(uuid)-> () in
            resultUuid = uuid
            print(resultUuid)
            e.fulfill()
        }, handler: WebErrorHandler())

        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertEqual(resultUuid.count, 36)

        let e1 = expectation(description: "ImageDownload")
        var resultData: Data!
        client.retrieveAccountAvatar(uuid: resultUuid, completion: {(d) -> () in
            resultData = d
            e1.fulfill()
        }, handler: WebErrorHandler())

        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(resultData)
        XCTAssertEqual(resultData, imageData)

        let retImage = UIImage(data: resultData)!
        XCTAssertEqual(retImage.size.width * retImage.scale, image.size.width * image.scale)
    }

    func testCreateAccountAndSetPassword_ShallSuccess() {
        XCTAssertNotNil(createTestUserAccount())
    }

    func testAuthAccount_ShallSuccess() {
        let handler = WebErrorHandler()
        handler.httpErrorHandler = { (s, e, m) -> Bool in
            let msg: String = "St: \(s), Err: \(e), Msg: \(m)"
            print(msg)
            return false
        }

        let accountResp = createTestUserAccount()
        let client = BackendServiceLocator.instance.getAccountClient()
        let e1 = expectation(description: "AuthAccount1")
        let password = "passw0rd"
        let passwordHash = SecretHelper.fillUserAccountPassword(account: accountResp, password: password)
        var tokenResp: AccountTokenResponse!
        client.logonUserAccount(accountName: accountResp.name!, passwordB64: passwordHash, deviceId: nil, completion: { (resp) in
            tokenResp = resp
            e1.fulfill()
        }, handler: handler)

        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(tokenResp.deviceId)
        XCTAssertNotNil(tokenResp.token)
        XCTAssertNotNil(tokenResp.serverTime)

        let token = tokenResp.token!

        // Auth again with device id, shall return the same token.
        let e2 = expectation(description: "AuthAccount2")
        client.logonUserAccount(accountName: accountResp.name!, passwordB64: passwordHash, deviceId: tokenResp.deviceId, completion: { (resp) in
            tokenResp = resp
            e2.fulfill()
        }, handler: handler)
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertEqual(tokenResp.token, token)

        // Auth again without device id, shall return a new token.
        let e3 = expectation(description: "AuthAccount3")
        client.logonUserAccount(accountName: accountResp.name!, passwordB64: passwordHash, deviceId: nil, completion: { (resp) in
            tokenResp = resp
            e3.fulfill()
        }, handler: handler)
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotEqual(tokenResp.token, token)
    }

    func createTestUserAccount() -> AccountResponse {
        let timeInterval = NSDate().timeIntervalSince1970
        let testAccountName = "xctest-\(Int(timeInterval))"

        // Create
        let e1 = expectation(description: "CreateAccount")
        let handler = WebErrorHandler()
        handler.httpErrorHandler = { (s, e, m) -> Bool in
            let msg: String = "St: \(s), Err: \(e), Msg: \(m)"
            print(msg)
            return false
        }

        let client = BackendServiceLocator.instance.getAccountClient()
        client.createUserAccount(accountName: testAccountName, displayName: "XCode 测试账号 \(Date())", completion: { (response)->Void in
            e1.fulfill()
        }, handler: handler)

        waitForExpectations(timeout: 5.0, handler: nil)

        // Retrieve
        let e2 = expectation(description: "GetAccount")
        var accountResp: AccountResponse!
        client.retrieveUserAccount(accountName: testAccountName, completion: { (response)->Void in
            accountResp = response
            e2.fulfill()
        }, handler: handler)

        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertEqual(testAccountName, accountResp.name)
        XCTAssertNotNil(accountResp.createdAt)

        // Update password
        let e3 = expectation(description: "UpdatePassword")
        let password = "passw0rd"
        let passwordHash = SecretHelper.fillUserAccountPassword(account: accountResp, password: password)
        client.updateUserAccountPassword(accountName: testAccountName, passwordB64: passwordHash, completion: { (response)->Void in
            accountResp = response
            e3.fulfill()
        }, handler: handler)
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertEqual(testAccountName, accountResp.name)
        XCTAssertNotNil(accountResp.createdAt)
        return accountResp
    }
}
