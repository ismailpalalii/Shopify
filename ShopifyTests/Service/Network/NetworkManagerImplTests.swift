import XCTest
import Alamofire
@testable import Shopify

final class NetworkManagerImplTests: XCTestCase {
    var sut: NetworkManagerImpl!

    override func setUp() {
        super.setUp()
        sut = NetworkManagerImpl()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_request_shouldFailWithInvalidURL() {
        let expectation = XCTestExpectation(description: "Should fail with invalid URL")
        sut.request(
            url: "invalid_url",
            method: .get,
            parameters: nil,
            headers: nil
        ) { (result: Result<Data, Error>) in
            switch result {
            case .success:
                XCTFail("Should not succeed with invalid URL")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
} 