import Alamofire
import Foundation
import RealmSwift

class ImageTypes {
    static let coreImage: Int = 0
    static let webImage1: Int = 1
}

class ImageContentTypes {
    static let jpeg: String = "image/jpeg"
}

class ImageRecord : Object {
    @objc dynamic var baseImageId: String = "" // A general ID field, could be core or web image.
    @objc dynamic var imageData: Data? = nil
    @objc dynamic var imageType: Int = 0
    @objc dynamic var contentType: String = ""

    override static func primaryKey() -> String? {
        return "baseImageId"
    }
}

class ImageManager {
    private let coreImageStore: Realm
    private let backendUrl: URL

    init(_ coreImageStore: Realm, _ backendServiceUrl: URL) {
        self.coreImageStore = coreImageStore
        self.backendUrl = backendServiceUrl
    }

    func getStoreCoreImageRecord(baseImageId: String) -> ImageRecord? {
        return self.coreImageStore.object(ofType: ImageRecord.self, forPrimaryKey: baseImageId)
    }

    func createStoreCoreImageRecord(baseImageId: String, imageType: Int, imageData: Data?, contentType: String) {
        let imageRecord = ImageRecord()
        imageRecord.baseImageId = baseImageId
        imageRecord.imageType = imageType
        imageRecord.imageData = imageData
        imageRecord.contentType = contentType
        try! self.coreImageStore.write {
            self.coreImageStore.add(imageRecord, update: true)
        }
    }

    func createCoreJpegImage(mainAccount: MainAccount, jpegImageData: Data, completion: @escaping (ImageRecord) -> Void, handler: WebErrorHandler) {
        let coreImagePostUrl = URL(string: "api/images/avatars", relativeTo: self.backendUrl)!
        var headers = WebHelper.getAuthHeader(account: mainAccount)
        headers["Content-Type"] = ImageContentTypes.jpeg
        Alamofire
            .upload(jpegImageData, to: coreImagePostUrl, method: .post, headers: headers)
            .responseJSON { response -> Void in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: NSDictionary) -> () in
                    let image = ImageRecord()
                    image.baseImageId = WebHelper.getResponseField(resp["image_id"] as? String)
                    image.contentType = WebHelper.getResponseField(resp["content_type"] as? String)
                    image.imageType = ImageTypes.coreImage
                    image.imageData = jpegImageData
                    completion(image)
                })
        }
    }

    func getCoreImage(mainAccount: MainAccount, coreImageId: String, completion: @escaping (ImageRecord) -> Void, handler: WebErrorHandler) {
        let coreImageGetUrl = URL(string: "api/images/core/\(coreImageId)", relativeTo: self.backendUrl)!
        Alamofire
            .request(coreImageGetUrl, method: .get, headers: WebHelper.getAuthHeader(account: mainAccount))
            .responseData { response in
                WebHelper.handleAlamofireResponse(handler: handler, response: response, complete: { (resp: Data) -> () in
                    let contentType = response.response?.allHeaderFields["Content-Type"] as? String
                    let image = ImageRecord()
                    image.baseImageId = coreImageId
                    image.contentType = WebHelper.getResponseField(contentType)
                    image.imageType = ImageTypes.coreImage
                    image.imageData = resp
                    completion(image)
                })
        }
    }
}
