import Foundation
import Alamofire

class WebErrorHandler {
    var networkIssueHandler: ((String) -> Bool)?
    var httpErrorHandler: [Int: (String) -> Bool]?
    var generalErrorHandler: ((String) -> Bool)?
    var upperCompletion: ((Bool) -> Void)?

    func httpError<Value>(statusCode: Int, response: DataResponse<Value>, function: String = #function) {
        print("HTTP error [\(function)] : \(statusCode)")
        var errorCode = statusCode
        var errorMsg = "HTTP Error \(statusCode)"
        if let handlers = self.httpErrorHandler {
            if let jsonResponse = response.result.value as? NSDictionary {
                if let code = jsonResponse["error_code"] as? Int {
                    errorCode = code
                }

                if let error = jsonResponse["error_message"] as? String {
                    errorMsg = error
                }
            }

            if let handler = handlers[errorCode] {
                if handler(errorMsg) {
                    if let completion = self.upperCompletion {
                        completion(false)
                    }
                    return
                }
            }
        }

        self.generalError(message: errorMsg, function: function)
    }

    func networkIssue(message: String, function: String = #function) {
        print("Network error [\(function)] : \(message)")
        if let handler = self.networkIssueHandler {
            if handler(message) {
                if let completion = self.upperCompletion {
                    completion(false)
                }
                return
            }
        }

        self.generalError(message: message, function: function)
    }

    func generalError(message: String, function: String = #function) {
        print("General web error [\(function)] : \(message)")
        if let handler = self.generalErrorHandler {
            if handler(message) {
                if let completion = self.upperCompletion {
                    completion(false)
                }
                return
            }
        }

        fatalError("Unhandled web error [@\(function)] : \(message)")
    }

    func addHandler(code: Int, handler: @escaping (String)->Bool) {
        if self.httpErrorHandler == nil {
            self.httpErrorHandler = [Int: (String) -> Bool]()
        }

        self.httpErrorHandler!.updateValue(handler, forKey: code)
    }
}

class WebHelper {
    static let authHeaderUserId = "X-Cchan-UserId"
    static let authHeaderToken = "X-Cchan-Token"

    private init() {}

    static func parseJsonDateString(date: String?) -> Date? {
        if let dateStr = date {
            let trimmedStr = dateStr.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: trimmedStr)
        } else {
            return nil
        }
    }

    static func getAuthHeader(account: MainAccount) -> HTTPHeaders {
        var ret = HTTPHeaders()
        ret[WebHelper.authHeaderUserId] = account.accountId
        ret[WebHelper.authHeaderToken] = "\(account.authDeviceId.value!):\(account.authToken!)"
        return ret
    }

    static func getResponseField<T>(_ data: T?) -> T {
        if data == nil {
            fatalError("Unexpected response received from remote server.")
        } else {
            return data!
        }
    }

    static func handleAlamofireResponse<Input, Output>(handler: WebErrorHandler, response: DataResponse<Input>, complete: @escaping (Output)->(), function: String = #function) {
        if let error = response.error {
            if let innerResponse = response.response {
                if innerResponse.statusCode >= 400 {
                    // handle http error response
                    handler.httpError(statusCode: innerResponse.statusCode, response: response, function: function)
                }
            }

            // handle only network issue
            handler.networkIssue(message: error.localizedDescription, function: function)
        } else if let innerResponse = response.response {
            if innerResponse.statusCode >= 400 {
                // handle http error response
                handler.httpError(statusCode: innerResponse.statusCode, response: response, function: function)
            } else if let output = response.result.value as? Output {
                complete(output)
            } else {
                handler.generalError(message: "Unexpected format of response from server.", function: function)
            }
        } else {
            handler.generalError(message: "Unexpected empty response from server.", function: function)
        }
    }
}
