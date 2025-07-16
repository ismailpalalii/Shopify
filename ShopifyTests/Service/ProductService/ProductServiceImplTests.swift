import XCTest
import Alamofire
@testable import Shopify

final class ProductServiceImplTests: XCTestCase {
    var sut: ProductServiceImpl!
    var mockNetworkManager: MockNetworkManager!

    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        sut = ProductServiceImpl(networkManager: mockNetworkManager)
    }

    override func tearDown() {
        sut = nil
        mockNetworkManager = nil
        super.tearDown()
    }

    func test_fetchAllProducts_success() {
        mockNetworkManager.shouldSucceed = true
        let expectation = XCTestExpectation(description: "Products fetched")
        sut.fetchAllProducts { result in
            switch result {
            case .success(let products):
                XCTAssertNotNil(products)
            case .failure:
                XCTFail("Should fetch products")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func test_fetchAllProducts_failure() {
        mockNetworkManager.shouldSucceed = false
        let expectation = XCTestExpectation(description: "Should fail to fetch products")
        sut.fetchAllProducts { result in
            switch result {
            case .success:
                XCTFail("Should not succeed")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

// Dummy MockNetworkManager for ProductServiceImplTests
class MockNetworkManager: NetworkManagerProtocol {
    var shouldSucceed = true
    func request<T: Decodable>(
        url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        headers: HTTPHeaders?,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        if shouldSucceed {
            if let products = [Product(id: "1", createdAt: "2024-01-01", name: "Test", image: "", price: "10.0 ₺", description: "", model: "", brand: "")] as? T {
                completion(.success(products))
            } else {
                completion(.failure(NSError(domain: "Test", code: -1)))
            }
        } else {
            completion(.failure(NSError(domain: "Test", code: -1)))
        }
    }
} 