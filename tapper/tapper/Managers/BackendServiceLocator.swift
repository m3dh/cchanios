import Foundation

class BackendServiceLocator {
    func getAccountManagerClient() -> AccountManagerClient {
        return AccountManagerClient(self.getHostServiceBaseUrl())
    }

    func getHostServiceBaseUrl() -> String {
        return "http://localhost:8080"
    }
}
