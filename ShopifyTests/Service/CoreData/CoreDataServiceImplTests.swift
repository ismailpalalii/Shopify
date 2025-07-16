import XCTest
@testable import Shopify

final class CoreDataServiceImplTests: XCTestCase {
    var sut: CoreDataServiceImpl!
    var testProduct: Product!

    override func setUp() {
        super.setUp()
        sut = CoreDataServiceImpl()
        testProduct = Product(id: "1", createdAt: "2024-01-01", name: "Test", image: "", price: "10.0 ₺", description: "", model: "", brand: "")
    }

    override func tearDown() {
        sut = nil
        testProduct = nil
        super.tearDown()
    }

    func test_loadFavoriteProductIDs_success() {
        let expectation = XCTestExpectation(description: "IDs loaded")
        sut.loadFavoriteProductIDs { result in
            switch result {
            case .success(let ids):
                XCTAssertNotNil(ids)
            case .failure:
                XCTFail("Should not fail")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func test_saveCartItem_and_loadCartItems() {
        let expectation = XCTestExpectation(description: "Cart item saved and loaded")
        sut.saveCartItem(testProduct, quantity: 1) { saveResult in
            switch saveResult {
            case .success:
                self.sut.loadCartItems { loadResult in
                    switch loadResult {
                    case .success(let items):
                        XCTAssertTrue(items.contains(where: { $0.id == self.testProduct.id }))
                    case .failure:
                        XCTFail("Should load cart items")
                    }
                    expectation.fulfill()
                }
            case .failure:
                XCTFail("Should save cart item")
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
} 