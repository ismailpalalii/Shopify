import XCTest
@testable import Shopify

final class NotificationManagerImplTests: XCTestCase {
    var sut: NotificationManagerImpl!

    override func setUp() {
        super.setUp()
        sut = NotificationManagerImpl()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_post_shouldTriggerObserver() {
        let expectation = XCTestExpectation(description: "Observer triggered")
        let observer = sut.observe(name: .cartUpdated) { notification in
            expectation.fulfill()
        }
        sut.post(name: .cartUpdated, object: nil)
        wait(for: [expectation], timeout: 1.0)
        sut.remove(observer: observer)
    }
} 