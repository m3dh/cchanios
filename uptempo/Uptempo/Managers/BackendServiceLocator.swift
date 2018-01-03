import Foundation

class BackendServiceLocator {
    static let instance = BackendServiceLocator()

    private init() {}

    func getAccountManagerClient() -> AccountManagerClient {
        return AccountManagerClient(self.getHostServiceBaseUrl())
    }

    func getHostServiceBaseUrl() -> String {
        return "http://localhost:8080"
    }
}
