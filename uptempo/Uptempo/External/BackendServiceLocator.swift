import Foundation

class BackendServiceLocator {
    static let instance = BackendServiceLocator()
    
    private init() {}
    
    func getAccountClient() -> AccountServiceClient {
        return AccountServiceClient(self.getHostServiceBaseUrl())
    }
    
    func getHostServiceBaseUrl() -> String {
        return "http://localhost:8080"
    }
}
