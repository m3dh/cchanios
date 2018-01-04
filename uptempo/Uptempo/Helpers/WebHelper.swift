import Foundation
import Alamofire

class WebErrorHandler {
    var networkIssueHandler: ((String) -> Bool)?
    var httpErrorHandler: ((Int, Int, String) -> Bool)?
    var generalErrorHandler: ((String) -> Bool)?

    func httpError<Value>(statusCode: Int, response: DataResponse<Value>, function: String = #function) {
        print("HTTP error [\(function)] : \(statusCode)")
        var errorCode = statusCode
        var errorMsg = "HTTP Error \(statusCode)"
        if let handler = self.httpErrorHandler {
            if let jsonResponse = response.result.value as? NSDictionary {
                if let code = jsonResponse["code"] as? Int {
                    errorCode = code
                }

                if let error = jsonResponse["error"] as? String {
                    errorMsg = error
                }
            }

            if handler(statusCode, errorCode, errorMsg) {
                return
            }
        }

        self.generalError(message: errorMsg, function: function)
    }

    func networkIssue(message: String, function: String = #function) {
        print("Network error [\(function)] : \(message)")
        if let handler = self.networkIssueHandler {
            if handler(message) {
                return
            }
        }

        self.generalError(message: message, function: function)
    }

    func generalError(message: String, function: String = #function) {
        print("General web error [\(function)] : \(message)")
        if let handler = self.generalErrorHandler {
            if handler(message) {
                return
            }
        }

        fatalError("Unhandled web error [@\(function)] : \(message)")
    }
}

class WebHelper {
    private init() {}

    static func parseJsonDateString(date: String) -> Date? {
        let trimmedStr = date.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: trimmedStr)
    }

    static func handleAlamofireResponse<Input, Output>(handler: WebErrorHandler, response: DataResponse<Input>, complete: @escaping (Output)->(), function: String = #function) {
        if let error = response.error {
            // handle network issue
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
