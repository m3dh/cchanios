import XCTest
@testable import Uptempo

class AccountManagerClientTests: XCTestCase {
    func testUploadAndDownloadAvatarImage_ShallSuccess() {
        let e = expectation(description: "ImageHelper")
        let image = UIImage(named: "Avatar - Default")!
        let client = BackendServiceLocator.instance.getAccountManagerClient()
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
        let e1 = expectation(description: "CreateAccount")
        let client = BackendServiceLocator.instance.getAccountManagerClient()
        client.createUserAccount(accountName: "xctestaccount", displayName: "XCode 测试账号", completion: { (response)->Void in
            e1.fulfill()
        }, handler: WebErrorHandler())

        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testResizeAvatarImage_ShalSuccess() {
        let image = UIImage(named: "Avatar - Default")!
        let result = ImageHelper.resizeSquareImageForAvatarUsage(image: image)
        XCTAssertEqual(result.scale, 2)
        XCTAssertEqual(result.size.width, result.size.height)
        XCTAssertEqual(result.size.width, 120)

        let imageData = ImageHelper.compressImageToJpeg(image: image, maxSize: 64)!
        XCTAssertLessThan(imageData.count, 64 * 1024)
    }
}
