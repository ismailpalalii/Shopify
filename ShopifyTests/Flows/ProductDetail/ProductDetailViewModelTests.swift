//
//  ProductDetailViewModelTests.swift
//  ShopifyTests
//
//  Created by İsmail Palalı on 15.07.2025.
//

import XCTest
@testable import Shopify

final class ProductDetailViewModelTests: XCTestCase {
    var sut: ProductDetailViewModel!
    var mockProductService: MockProductService!
    var mockCoreDataService: MockCoreDataService!
    var mockNotificationManager: MockNotificationManager!
    var testProduct: Product!
    
    override func setUp() {
        super.setUp()
        mockProductService = MockProductService()
        mockCoreDataService = MockCoreDataService()
        mockNotificationManager = MockNotificationManager()
        
        // Reset all mock services to ensure clean state
        mockProductService.reset()
        mockCoreDataService.reset()
        mockNotificationManager.reset()
        
        testProduct = createMockProduct()
        
        sut = ProductDetailViewModel(
            product: testProduct,
            productService: mockProductService,
            coreDataService: mockCoreDataService,
            notificationManager: mockNotificationManager
        )
    }
    
    override func tearDown() {
        // Reset all mock services before cleanup
        mockProductService?.reset()
        mockCoreDataService?.reset()
        mockNotificationManager?.reset()
        
        sut = nil
        mockProductService = nil
        mockCoreDataService = nil
        mockNotificationManager = nil
        testProduct = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_shouldSetProduct() {
        // Then
        XCTAssertEqual(sut.product.id, testProduct.id)
        XCTAssertEqual(sut.product.name, testProduct.name)
        XCTAssertEqual(sut.product.brand, testProduct.brand)
        XCTAssertEqual(sut.product.model, testProduct.model)
        XCTAssertEqual(sut.product.price, testProduct.price)
        XCTAssertEqual(sut.product.description, testProduct.description)
        XCTAssertEqual(sut.product.image, testProduct.image)
    }
    
    func test_initialization_shouldLoadFavoriteStatus() {
        // Given
        let expectation = XCTestExpectation(description: "Favorite status loaded")
        
        // When
        sut.onFavoriteStatusChange = { isFavorite in
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(sut.isFavorite) // Default should be false
    }
    
    func test_initialization_whenProductIsFavorite_shouldSetFavoriteStatus() {
        // Given
        mockCoreDataService.mockFavoriteIDs = [testProduct.id]
        
        let expectation = XCTestExpectation(description: "Favorite status loaded")
        
        // When
        sut.onFavoriteStatusChange = { isFavorite in
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.isFavorite)
    }
    
    func test_initialization_whenProductIsNotFavorite_shouldSetFavoriteStatus() {
        // Given
        mockCoreDataService.mockFavoriteIDs = ["other-product-id"]
        
        let expectation = XCTestExpectation(description: "Favorite status loaded")
        
        // When
        sut.onFavoriteStatusChange = { isFavorite in
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(sut.isFavorite)
    }
    
    // MARK: - Toggle Favorite Tests
    
    func test_toggleFavorite_whenNotFavorite_shouldAddToFavorites() {
        // Given
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Favorite status changed")
        
        sut.onFavoriteStatusChange = { isFavorite in
            if isFavorite {
                expectation.fulfill()
            }
        }
        
        // When
        sut.toggleFavorite()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockCoreDataService.saveFavoriteProductIDCalled)
        XCTAssertEqual(mockCoreDataService.savedProductID, testProduct.id)
        XCTAssertTrue(sut.isFavorite)
    }
    
    func test_toggleFavorite_whenAlreadyFavorite_shouldRemoveFromFavorites() {
        // Given
        mockCoreDataService.mockFavoriteIDs = [testProduct.id]
        mockCoreDataService.shouldSucceed = true
        
        // Wait for initial favorite status to load
        let initialExpectation = XCTestExpectation(description: "Initial favorite status loaded")
        sut.onFavoriteStatusChange = { isFavorite in
            if isFavorite {
                initialExpectation.fulfill()
            }
        }
        wait(for: [initialExpectation], timeout: 1.0)
        
        // When
        sut.toggleFavorite()
        
        // Then - wait a bit for the async operation to complete
        let expectation = XCTestExpectation(description: "Toggle operation completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockCoreDataService.removeFavoriteProductIDCalled)
        XCTAssertEqual(mockCoreDataService.removedProductID, testProduct.id)
        XCTAssertFalse(sut.isFavorite)
    }
    
    func test_toggleFavorite_whenSaveFails_shouldCallErrorCallback() {
        // Given
        mockCoreDataService.shouldSucceed = false
        mockCoreDataService.mockError = CoreDataServiceError.saveFailed(NSError(domain: "TestError", code: -1, userInfo: nil))
        
        let expectation = XCTestExpectation(description: "Error callback called")
        
        sut.onError = { error in
            expectation.fulfill()
        }
        
        // When
        sut.toggleFavorite()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockCoreDataService.saveFavoriteProductIDCalled)
        XCTAssertFalse(sut.isFavorite) // Should remain false
    }
    
    func test_toggleFavorite_whenRemoveFails_shouldCallErrorCallback() {
        // Given - First set up the initial favorite status
        mockCoreDataService.mockFavoriteIDs = [testProduct.id]
        mockCoreDataService.shouldSucceed = true // Allow initial load to succeed
        
        // Wait for initial favorite status to load
        let initialExpectation = XCTestExpectation(description: "Initial favorite status loaded")
        sut.onFavoriteStatusChange = { isFavorite in
            if isFavorite {
                initialExpectation.fulfill()
            }
        }
        wait(for: [initialExpectation], timeout: 1.0)
        
        // Now set up for the toggle operation to fail
        mockCoreDataService.shouldSucceed = false
        mockCoreDataService.mockError = CoreDataServiceError.deleteFailed(NSError(domain: "TestError", code: -1, userInfo: nil))
        
        var errorCallbackCalled = false
        sut.onError = { error in
            errorCallbackCalled = true
        }
        
        // When
        sut.toggleFavorite()
        
        // Then - wait a bit for the async operation to complete
        let expectation = XCTestExpectation(description: "Toggle operation completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockCoreDataService.removeFavoriteProductIDCalled)
        XCTAssertTrue(errorCallbackCalled)
        XCTAssertTrue(sut.isFavorite) // Should remain true
    }
    
    // MARK: - Add to Cart Tests
    
    func test_addToCart_whenSuccessful_shouldPostNotification() {
        // Given
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Cart operation completed")
        
        // When
        sut.addToCart(testProduct)
        
        // Wait for the async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(mockCoreDataService.saveCartItemCalled)
        XCTAssertEqual(mockCoreDataService.savedCartProduct?.id, testProduct.id)
        XCTAssertTrue(mockNotificationManager.postCalled)
        XCTAssertEqual(mockNotificationManager.postedNotificationName, .cartUpdated)
    }
    
    func test_addToCart_whenSuccessful_shouldSaveToCoreData() {
        // Given
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Cart operation completed")
        
        // When
        sut.addToCart(testProduct, quantity: 2)
        
        // Wait for the async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(mockCoreDataService.saveCartItemCalled)
        XCTAssertEqual(mockCoreDataService.savedCartProduct?.id, testProduct.id)
    }
    
    func test_addToCart_whenFails_shouldCallErrorCallback() {
        // Given
        mockCoreDataService.shouldSucceed = false
        mockCoreDataService.mockError = CoreDataServiceError.saveFailed(NSError(domain: "TestError", code: -1, userInfo: nil))
        
        let expectation = XCTestExpectation(description: "Error callback called")
        
        sut.onError = { error in
            expectation.fulfill()
        }
        
        // When
        sut.addToCart(testProduct)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockCoreDataService.saveCartItemCalled)
        XCTAssertFalse(mockNotificationManager.postCalled) // Should not post notification on failure
    }
    
    // MARK: - Product Properties Tests
    
    func test_productProperties_shouldReturnCorrectValues() {
        // Then
        XCTAssertEqual(sut.product.id, "1")
        XCTAssertEqual(sut.product.name, "iPhone 15 Pro")
        XCTAssertEqual(sut.product.brand, "Apple")
        XCTAssertEqual(sut.product.model, "iPhone 15")
        XCTAssertEqual(sut.product.price, "999.99 ₺")
        XCTAssertEqual(sut.product.description, "Latest iPhone model")
        XCTAssertEqual(sut.product.image, "https://example.com/iphone.jpg")
    }
    
    // MARK: - Callback Tests
    
    func test_onFavoriteStatusChange_shouldBeCalledWhenStatusChanges() {
        // Given
        var callbackCalled = false
        var callbackValue: Bool?
        
        sut.onFavoriteStatusChange = { isFavorite in
            callbackCalled = true
            callbackValue = isFavorite
        }
        
        // When - trigger favorite status change by setting up mock and calling toggle
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Favorite status changed")
        sut.onFavoriteStatusChange = { isFavorite in
            if isFavorite {
                callbackCalled = true
                callbackValue = isFavorite
                expectation.fulfill()
            }
        }
        
        sut.toggleFavorite()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(callbackCalled)
        XCTAssertEqual(callbackValue, true)
    }
    
    func test_onError_shouldBeCalledWhenErrorOccurs() {
        // Given
        var errorCallbackCalled = false
        var receivedError: Error?
        
        sut.onError = { error in
            errorCallbackCalled = true
            receivedError = error
        }
        
        // When
        mockCoreDataService.shouldSucceed = false
        mockCoreDataService.mockError = CoreDataServiceError.saveFailed(NSError(domain: "TestError", code: -1, userInfo: nil))
        sut.toggleFavorite()
        
        // Then - wait a bit for the async operation to complete
        let expectation = XCTestExpectation(description: "Toggle operation completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(errorCallbackCalled)
        XCTAssertNotNil(receivedError)
    }
    
    // MARK: - Edge Cases Tests
    
    func test_toggleFavorite_whenCoreDataServiceFails_shouldHandleGracefully() {
        // Given
        mockCoreDataService.shouldSucceed = false
        
        let expectation = XCTestExpectation(description: "Error handled")
        
        sut.onError = { error in
            expectation.fulfill()
        }
        
        // When
        sut.toggleFavorite()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(sut.isFavorite) // Should remain unchanged
    }
    
    func test_addToCart_withDifferentProduct_shouldWorkCorrectly() {
        // Given
        let differentProduct = Product(
            id: "2",
            createdAt: "2024-01-02",
            name: "Samsung Galaxy S24",
            image: "https://example.com/samsung.jpg",
            price: "899.99 ₺",
            description: "Latest Samsung model",
            model: "Galaxy S24",
            brand: "Samsung"
        )
        
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Cart operation completed")
        
        // When
        sut.addToCart(differentProduct)
        
        // Wait for the async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(mockCoreDataService.saveCartItemCalled)
        XCTAssertEqual(mockCoreDataService.savedCartProduct?.id, "2")
        XCTAssertEqual(mockCoreDataService.savedCartProduct?.name, "Samsung Galaxy S24")
    }
} 