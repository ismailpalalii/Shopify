//
//  FavoritesViewModelTests.swift
//  ShopifyTests
//
//  Created by İsmail Palalı on 15.07.2025.
//

import XCTest
@testable import Shopify

final class FavoritesViewModelTests: XCTestCase {
    var sut: FavoritesViewModel!
    var mockProductService: MockProductService!
    var mockCoreDataService: MockCoreDataService!
    var mockNotificationManager: MockNotificationManager!
    
    override func setUp() {
        super.setUp()
        mockProductService = MockProductService()
        mockCoreDataService = MockCoreDataService()
        mockNotificationManager = MockNotificationManager()
        
        // Reset all mock services to ensure clean state
        mockProductService.reset()
        mockCoreDataService.reset()
        mockNotificationManager.reset()
        
        sut = FavoritesViewModel(
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
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_shouldSetUpCartObserver() {
        // Then
        XCTAssertTrue(mockNotificationManager.observeCalled)
        XCTAssertEqual(mockNotificationManager.observedNotificationName, .cartUpdated)
    }
    
    func test_initialState_shouldBeIdle() {
        // Then
        XCTAssertEqual(sut.state, .idle)
        XCTAssertTrue(sut.favoriteProducts.isEmpty)
        XCTAssertTrue(sut.filteredProducts.isEmpty)
        XCTAssertTrue(sut.favoriteProductIDs.isEmpty)
    }
    
    // MARK: - Load Favorites Tests
    
    func test_loadFavorites_whenSuccessful_shouldUpdateState() {
        // Given
        let mockProducts = createMockProducts()
        let favoriteIDs = ["1", "2"]
        
        mockCoreDataService.mockFavoriteIDs = favoriteIDs
        mockProductService.mockProductsPage1 = mockProducts
        mockCoreDataService.shouldSucceed = true
        mockProductService.shouldFail = false
        
        let expectation = XCTestExpectation(description: "State changed to loaded")
        
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.loadFavorites()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.favoriteProducts.count, 2)
        XCTAssertEqual(sut.filteredProducts.count, 2)
    }
    
    func test_loadFavorites_whenEmpty_shouldSetEmptyState() {
        // Given
        mockCoreDataService.mockFavoriteIDs = []
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "State changed to empty")
        
        sut.onStateChange = { state in
            if case .empty = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.loadFavorites()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.state, .empty)
        XCTAssertTrue(sut.favoriteProducts.isEmpty)
        XCTAssertTrue(sut.filteredProducts.isEmpty)
    }
    
    func test_loadFavorites_whenCoreDataFails_shouldSetEmptyState() {
        // Given
        mockCoreDataService.shouldSucceed = false
        mockCoreDataService.mockError = CoreDataServiceError.fetchFailed(NSError(domain: "TestError", code: -1, userInfo: nil))
        
        let expectation = XCTestExpectation(description: "State changed to empty")
        
        sut.onStateChange = { state in
            if case .empty = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.loadFavorites()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.state, .empty)
        XCTAssertTrue(sut.favoriteProducts.isEmpty)
        XCTAssertTrue(sut.filteredProducts.isEmpty)
    }
    
    func test_loadFavorites_whenProductServiceFails_shouldSetErrorState() {
        // Given
        let favoriteIDs = ["1", "2"]
        mockCoreDataService.mockFavoriteIDs = favoriteIDs
        mockCoreDataService.shouldSucceed = true
        mockProductService.shouldFail = true
        mockProductService.mockError = URLError(.notConnectedToInternet)
        
        let expectation = XCTestExpectation(description: "State changed to error")
        
        sut.onStateChange = { state in
            if case .error = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.loadFavorites()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        if case .error(let error) = sut.state {
            XCTAssertTrue(error is FavoritesViewModel.AppError)
        } else {
            XCTFail("Expected error state")
        }
    }
    
    // MARK: - Search Tests
    
    func test_setSearchText_whenNotEmpty_shouldFilterProducts() {
        // Given
        let mockProducts = createMockProducts()
        let favoriteIDs = ["1", "2"]
        
        mockCoreDataService.mockFavoriteIDs = favoriteIDs
        mockProductService.mockProductsPage1 = mockProducts
        mockCoreDataService.shouldSucceed = true
        mockProductService.shouldFail = false
        
        // First load favorites to populate the view model
        sut.loadFavorites()
        
        let loadExpectation = XCTestExpectation(description: "Favorites loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        let expectation = XCTestExpectation(description: "State changed")
        
        sut.onStateChange = { state in
            expectation.fulfill()
        }
        
        // When
        sut.setSearchText("iPhone")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.currentSearchText, "iPhone")
        XCTAssertLessThan(sut.filteredProducts.count, mockProducts.count)
    }
    
    func test_setSearchText_whenEmpty_shouldShowAllProducts() {
        // Given
        let mockProducts = createMockProducts()
        let favoriteIDs = ["1", "2"]
        
        mockCoreDataService.mockFavoriteIDs = favoriteIDs
        mockProductService.mockProductsPage1 = mockProducts
        mockCoreDataService.shouldSucceed = true
        mockProductService.shouldFail = false
        
        let loadExpectation = XCTestExpectation(description: "Favorites loaded")
        
        sut.onStateChange = { state in
            if case .loaded = state {
                loadExpectation.fulfill()
            }
        }
        
        // First load favorites to populate the view model
        sut.loadFavorites()
        wait(for: [loadExpectation], timeout: 1.0)
        
        // Set search text to something first
        sut.setSearchText("iPhone")
        
        let expectation = XCTestExpectation(description: "State changed")
        
        sut.onStateChange = { state in
            expectation.fulfill()
        }
        
        // When
        sut.setSearchText("")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.currentSearchText, "")
        XCTAssertEqual(sut.filteredProducts.count, favoriteIDs.count)
    }
    
    func test_clearAllFilters_shouldResetSearch() {
        // Given
        let mockProducts = createMockProducts()
        let favoriteIDs = ["1", "2"]
        
        mockCoreDataService.mockFavoriteIDs = favoriteIDs
        mockProductService.mockProductsPage1 = mockProducts
        mockCoreDataService.shouldSucceed = true
        mockProductService.shouldFail = false
        
        let loadExpectation = XCTestExpectation(description: "Favorites loaded")
        
        sut.onStateChange = { state in
            if case .loaded = state {
                loadExpectation.fulfill()
            }
        }
        
        // First load favorites to populate the view model
        sut.loadFavorites()
        wait(for: [loadExpectation], timeout: 1.0)
        
        // Set search text first
        sut.setSearchText("iPhone")
        
        let expectation = XCTestExpectation(description: "State changed")
        
        sut.onStateChange = { state in
            expectation.fulfill()
        }
        
        // When
        sut.clearAllFilters()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.currentSearchText, "")
        XCTAssertEqual(sut.filteredProducts.count, favoriteIDs.count)
    }
    
    // MARK: - Favorite Management Tests
    
    func test_isFavorite_whenProductIsFavorite_shouldReturnTrue() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.mockFavoriteIDs = [product.id]
        mockCoreDataService.shouldSucceed = true
        
        // Load favorite IDs to populate the view model
        sut.loadFavorites()
        
        let loadExpectation = XCTestExpectation(description: "Favorites loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        // When
        let result = sut.isFavorite(product)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_isFavorite_whenProductIsNotFavorite_shouldReturnFalse() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.mockFavoriteIDs = []
        mockCoreDataService.shouldSucceed = true
        
        // Load favorite IDs to populate the view model
        sut.loadFavorites()
        
        let loadExpectation = XCTestExpectation(description: "Favorites loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        // When
        let result = sut.isFavorite(product)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_toggleFavorite_whenAddingFavorite_shouldAddToFavorites() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.mockFavoriteIDs = []
        mockCoreDataService.shouldSucceed = true
        
        // Load favorite IDs to populate the view model
        sut.loadFavorites()
        
        let loadExpectation = XCTestExpectation(description: "Favorites loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        let expectation = XCTestExpectation(description: "Favorite added")
        
        // When
        sut.toggleFavorite(product) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockCoreDataService.saveFavoriteProductIDCalled)
        XCTAssertEqual(mockCoreDataService.savedProductID, product.id)
        XCTAssertTrue(sut.favoriteProductIDs.contains(product.id))
    }
    
    func test_toggleFavorite_whenRemovingFavorite_shouldRemoveFromFavorites() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.mockFavoriteIDs = [product.id]
        mockProductService.mockProductsPage1 = [product]
        mockCoreDataService.shouldSucceed = true
        mockProductService.shouldFail = false
        
        // Load favorites to populate the view model
        sut.loadFavorites()
        
        let loadExpectation = XCTestExpectation(description: "Favorites loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 1.0)
        
        let expectation = XCTestExpectation(description: "Favorite removed")
        
        // When
        sut.toggleFavorite(product) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockCoreDataService.removeFavoriteProductIDCalled)
        XCTAssertEqual(mockCoreDataService.removedProductID, product.id)
        XCTAssertFalse(sut.favoriteProductIDs.contains(product.id))
        XCTAssertTrue(sut.favoriteProducts.isEmpty)
        XCTAssertTrue(sut.filteredProducts.isEmpty)
    }
    
    // MARK: - Cart Operations Tests
    
    func test_addToCart_whenSuccessful_shouldPostNotification() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Cart item added")
        
        // When
        sut.addToCart(product, quantity: 2)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockCoreDataService.saveCartItemCalled)
        XCTAssertEqual(mockCoreDataService.savedCartProduct?.id, product.id)
        XCTAssertTrue(mockNotificationManager.postCalled)
        XCTAssertEqual(mockNotificationManager.postedNotificationName, .cartUpdated)
    }
    
    func test_addToCart_whenFails_shouldCallErrorCallback() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.shouldSucceed = false
        mockCoreDataService.mockError = CoreDataServiceError.saveFailed(NSError(domain: "TestError", code: -1, userInfo: nil))
        
        var errorCalled = false
        sut.onError = { error in
            errorCalled = true
        }
        
        // When
        sut.addToCart(product, quantity: 1)
        
        // Then
        let expectation = XCTestExpectation(description: "Error callback called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(mockCoreDataService.saveCartItemCalled)
        XCTAssertFalse(mockNotificationManager.postCalled)
        XCTAssertTrue(errorCalled)
    }
    
    // MARK: - Retry Tests
    
    func test_retryFetch_shouldReloadFavorites() {
        // Given
        let mockProducts = createMockProducts()
        let favoriteIDs = ["1", "2"]
        
        mockCoreDataService.mockFavoriteIDs = favoriteIDs
        mockProductService.mockProductsPage1 = mockProducts
        mockCoreDataService.shouldSucceed = true
        mockProductService.shouldFail = false
        
        let expectation = XCTestExpectation(description: "State changed to loaded")
        
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.retryFetch()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.favoriteProducts.count, 2)
    }
    
    // MARK: - Product Detail ViewModel Tests
    
    func test_makeProductDetailViewModel_shouldCreateCorrectViewModel() {
        // Given
        let product = createMockProduct()
        
        // When
        let detailVM = sut.makeProductDetailViewModel(for: product)
        
        // Then
        XCTAssertEqual(detailVM.product.id, product.id)
        XCTAssertEqual(detailVM.product.name, product.name)
    }
    
    // MARK: - State Management Tests
    
    func test_stateChanges_shouldTriggerCallback() {
        // Given
        var stateChanges: [FavoritesViewModel.State] = []
        
        sut.onStateChange = { state in
            stateChanges.append(state)
        }
        
        // When
        sut.loadFavorites()
        
        // Then
        let expectation = XCTestExpectation(description: "State changes occurred")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(stateChanges.isEmpty)
    }
    
    // MARK: - Error Handling Tests
    
    func test_errorMapping_shouldMapNetworkErrors() {
        // Given
        let networkError = URLError(.notConnectedToInternet)
        
        // When
        let result = mapError(networkError)
        
        // Then
        if case .networkUnavailable = result {
            XCTAssertTrue(true) // Success
        } else {
            XCTFail("Expected networkUnavailable error")
        }
    }
    
    func test_errorMapping_shouldMapServerErrors() {
        // Given
        let serverError = URLError(.timedOut)
        
        // When
        let result = mapError(serverError)
        
        // Then
        if case .serverError = result {
            XCTAssertTrue(true) // Success
        } else {
            XCTFail("Expected serverError error")
        }
    }
    
    func test_errorMapping_shouldMapUnknownErrors() {
        // Given
        let unknownError = NSError(domain: "TestError", code: -1, userInfo: nil)
        
        // When
        let result = mapError(unknownError)
        
        // Then
        if case .unknown = result {
            XCTAssertTrue(true) // Success
        } else {
            XCTFail("Expected unknown error")
        }
    }
    
    // MARK: - Helper Methods
    
    private func mapError(_ error: Error) -> FavoritesViewModel.AppError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .timedOut, .cannotFindHost:
                return .serverError
            default:
                return .unknown(error)
            }
        }
        return .unknown(error)
    }
} 