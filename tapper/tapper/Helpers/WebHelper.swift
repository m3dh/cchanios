import Foundation
import Alamofire

class WebHelper {
    private init() {}

    static func isErrorHttpStatusCode(_ code: Int) -> Bool {
        return code >= 400
    }

    static func tryGetWebErrorMessageFrom<Value>(response: DataResponse<Value>, functionName: String = #function) -> (Bool, String) {
        if let error = response.error {
            print("Web error [\(functionName)] : \(error)")
            return (true, "Web error occurred.")
        } else if let innerResponse = response.response {
            if WebHelper.isErrorHttpStatusCode(innerResponse.statusCode) {
                print("Http error [\(functionName)], response : \(innerResponse)")
                return (true, "Http error code \(innerResponse.statusCode) returned.")
            }
        }

        return (false, "")
    }
}
