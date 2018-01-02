import XCTest
@testable import Tapper

class AccountManagerClientTests: XCTestCase {
    func go(closure: ()->()) {
        closure()
    }

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
        }, failure: {(msg)->Void in fatalError(msg)})

        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertEqual(resultUuid.count, 36)

        let e1 = expectation(description: "ImageDownload")
        var resultData: Data!
        client.retrieveAccountAvatar(uuid: resultUuid, completion: {(d) -> () in
            resultData = d
            e1.fulfill()
        }, failure: {(msg)->Void in fatalError(msg)})

        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(resultData)
        XCTAssertEqual(resultData, imageData)

        let retImage = UIImage(data: resultData)!
        XCTAssertEqual(retImage.size.width * retImage.scale, image.size.width * image.scale)
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
