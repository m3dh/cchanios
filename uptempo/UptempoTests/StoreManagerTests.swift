import XCTest
import Foundation
import RealmSwift
@testable import Uptempo

class StoreManagerTests: XCTestCase {
    override func tearDown() {
        let store = PersistStoreClient()
        try! store.mainDb.write {
            store.mainDb.deleteAll()
        }

        super.tearDown()
    }

    func testStoreManager_ShallAbleToLoadDefaultDb() {
        let store = PersistStoreClient()
        XCTAssertNotNil(store)

        var mainAccount = store.getMainAccount()
        XCTAssertNil(mainAccount)

        let accountResq = MainAccount()
        accountResq.name = "account-name"
        accountResq.displayName = "Account Display Name"
        accountResq.createdAt = Date()
        store.putMainAccount(account: accountResq)

        mainAccount = store.getMainAccount()
        XCTAssertNotNil(mainAccount)
        XCTAssertEqual(mainAccount!.displayName, accountResq.displayName)
        XCTAssertNil(mainAccount!.authToken)

        store.setMainAccount(update: {account->Void in
            account.authToken = "Token-1-2-3-4-5"
        })

        XCTAssertEqual("Token-1-2-3-4-5", mainAccount!.authToken)
    }
}
