import XCTest
import Foundation
@testable import Uptempo

class HelperUnittests: XCTestCase {
    func testSecretHelpers() {
        let inputDict: NSDictionary = [
            "CreatedAt":"2018-01-04T09:04:31Z",
            "Name":"accountName",
            "DisplayName":"Display Name"
        ]
        let accountResp = AccountResponse(inputDict)

        let hash = SecretHelper.fillUserAccountPassword(account: accountResp, password: "passw0rd")
        XCTAssertEqual("IzaWA1H/31Nnl1v91G1ce3GnpzA=", hash)
    }

    func testResizeAvatarImage() {
        let image = UIImage(named: "Avatar - Default")!
        let result = ImageHelper.resizeSquareImageForAvatarUsage(image: image)
        XCTAssertEqual(result.scale, 2)
        XCTAssertEqual(result.size.width, result.size.height)
        XCTAssertEqual(result.size.width, 120)

        let imageData = ImageHelper.compressImageToJpeg(image: image, maxSize: 64)!
        XCTAssertLessThan(imageData.count, 64 * 1024)
    }
}
