//
//  ProductListViewModelTests.swift
//  ShopifyTests
//
//  Created by İsmail Palalı on 15.07.2025.
//

import XCTest
@testable import Shopify

final class ProductListViewModelTests: XCTestCase {
    var sut: ProductListViewModel!
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
        
        sut = ProductListViewModel(
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
    
    // MARK: - Initial State Tests
    
    func test_initialState_shouldBeIdle() {
        XCTAssertEqual(sut.state, .idle)
        XCTAssertTrue(sut.products.isEmpty)
        XCTAssertTrue(sut.filteredProducts.isEmpty)
        XCTAssertFalse(sut.isLastPage)
        XCTAssertFalse(sut.isFetching)
    }
    
    // MARK: - Load Products Tests
    
    func test_fetchFirstPage_whenSuccessful_shouldUpdateStateToLoaded() {
        // Given
        let expectation = XCTestExpectation(description: "Products loaded")
        let mockProducts = createMockProducts()
        mockProductService.mockProductsPage1 = mockProducts
        
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.fetchFirstPage()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.products.count, 4)
        XCTAssertEqual(sut.filteredProducts.count, 4)
    }
    
    func test_fetchFirstPage_whenEmptyResponse_shouldUpdateStateToEmpty() {
        // Given
        let expectation = XCTestExpectation(description: "Empty state")
        mockProductService.mockProductsPage1 = []
        
        sut.onStateChange = { state in
            if case .empty = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.fetchFirstPage()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.products.isEmpty)
        XCTAssertTrue(sut.filteredProducts.isEmpty)
    }
    
    func test_fetchFirstPage_whenNetworkError_shouldUpdateStateToError() {
        // Given
        let expectation = XCTestExpectation(description: "Error state")
        mockProductService.shouldFail = true
        mockProductService.mockError = URLError(.notConnectedToInternet)
        
        sut.onStateChange = { state in
            if case .error = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.fetchFirstPage()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(sut.products.isEmpty)
    }
    
    // MARK: - Pagination Tests
    
    func test_fetchNextPage_shouldAppendProducts() {
        // Given
        let expectation = XCTestExpectation(description: "Next page loaded")
        
        // Reset mock service to ensure clean state
        mockProductService.reset()
        
        let initialProducts = createMockProducts()
        let nextPageProducts = createMockProductsForNextPage()
        
        mockProductService.mockProductsPage1 = initialProducts
        mockProductService.mockProductsPage2 = nextPageProducts
        
        // Load first page
        let firstPageExpectation = XCTestExpectation(description: "First page loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                firstPageExpectation.fulfill()
            }
        }
        
        sut.fetchFirstPage()
        wait(for: [firstPageExpectation], timeout: 1.0)
        
        // Verify first page loaded correctly
        XCTAssertEqual(sut.products.count, 4)
        
        // Load second page
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.fetchNextPage()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        // Add a small delay to ensure all async operations complete
        let finalExpectation = XCTestExpectation(description: "Final check")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            finalExpectation.fulfill()
        }
        wait(for: [finalExpectation], timeout: 1.0)
        
        // Verify we have products from both pages
        XCTAssertEqual(sut.products.count, 8) // 4 + 4
        let allProductIDs = sut.products.map { $0.id }
        XCTAssertTrue(allProductIDs.contains("1"))
        XCTAssertTrue(allProductIDs.contains("2"))
        XCTAssertTrue(allProductIDs.contains("3"))
        XCTAssertTrue(allProductIDs.contains("4"))
        XCTAssertTrue(allProductIDs.contains("5"))
        XCTAssertTrue(allProductIDs.contains("6"))
        XCTAssertTrue(allProductIDs.contains("7"))
        XCTAssertTrue(allProductIDs.contains("8"))
    }
    
    func test_fetchNextPage_whenLastPage_shouldNotFetch() {
        // Given
        let products = createMockProducts()
        mockProductService.mockProductsPage1 = products
        mockProductService.mockProductsPage2 = [] // Empty second page
        
        // Load first page
        let firstPageExpectation = XCTestExpectation(description: "First page loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                firstPageExpectation.fulfill()
            }
        }
        
        sut.fetchFirstPage()
        wait(for: [firstPageExpectation], timeout: 1.0)
        
        let initialCount = sut.products.count
        
        // When
        sut.fetchNextPage()
        
        // Then
        XCTAssertEqual(sut.products.count, initialCount)
    }
    
    // MARK: - Search Tests
    
    func test_setSearchText_whenValidText_shouldFilterProducts() {
        // Given
        // Reset mock service to ensure clean state
        mockProductService.reset()
        
        let products = createMockProducts()
        mockProductService.mockProductsPage1 = products
        mockProductService.mockProductsPage2 = [] // Empty second page for search
        
        let loadExpectation = XCTestExpectation(description: "Products loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                loadExpectation.fulfill()
            }
        }
        
        sut.fetchFirstPage()
        wait(for: [loadExpectation], timeout: 1.0)
        
        // When
        sut.setSearchText("iPhone")
        
        // Wait for search to complete (it's async)
        let searchExpectation = XCTestExpectation(description: "Search completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            searchExpectation.fulfill()
        }
        wait(for: [searchExpectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(sut.filteredProducts.count <= products.count)
        XCTAssertTrue(sut.filteredProducts.allSatisfy { $0.name.lowercased().contains("iphone") })
        XCTAssertTrue(sut.filteredProducts.count > 0) // Should find at least one iPhone product
    }
    
    func test_setSearchText_whenEmptyText_shouldShowAllProducts() {
        // Given
        let products = createMockProducts()
        mockProductService.mockProductsPage1 = products
        
        let loadExpectation = XCTestExpectation(description: "Products loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                loadExpectation.fulfill()
            }
        }
        
        sut.fetchFirstPage()
        wait(for: [loadExpectation], timeout: 1.0)
        
        // When
        sut.setSearchText("")
        
        // Then
        XCTAssertEqual(sut.filteredProducts.count, products.count)
    }
    
    // MARK: - Filter Tests
    
    func test_applyFilter_whenBrandFilter_shouldFilterByBrand() {
        // Given
        let products = createMockProducts()
        mockProductService.mockProductsPage1 = products
        
        let loadExpectation = XCTestExpectation(description: "Products loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                loadExpectation.fulfill()
            }
        }
        
        sut.fetchFirstPage()
        wait(for: [loadExpectation], timeout: 1.0)
        
        var filterData = FilterData()
        filterData.selectedBrands = ["Apple"]
        
        // When
        sut.applyFilter(filterData)
        
        // Then
        XCTAssertTrue(sut.filteredProducts.allSatisfy { $0.brand == "Apple" })
    }
    
    // MARK: - Favorites Tests
    
    func test_toggleFavorite_whenNotFavorite_shouldAddToFavorites() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.shouldSucceed = true
        
        // When
        sut.toggleFavorite(product)
        
        // Then
        XCTAssertTrue(mockCoreDataService.saveFavoriteProductIDCalled)
        XCTAssertEqual(mockCoreDataService.savedProductID, product.id)
    }
    
    func test_toggleFavorite_whenAlreadyFavorite_shouldRemoveFromFavorites() {
        // Given
        let product = createMockProduct()
        setupFavoritesState(favoriteIDs: [product.id])
        
        // When
        sut.toggleFavorite(product)
        
        // Then
        XCTAssertTrue(mockCoreDataService.removeFavoriteProductIDCalled)
        XCTAssertEqual(mockCoreDataService.removedProductID, product.id)
    }
    
    func test_isFavorite_whenProductInFavorites_shouldReturnTrue() {
        // Given
        let product = createMockProduct()
        setupFavoritesState(favoriteIDs: [product.id])
        
        // When & Then
        XCTAssertTrue(sut.isFavorite(product))
    }
    
    func test_isFavorite_whenProductNotInFavorites_shouldReturnFalse() {
        // Given
        let product = createMockProduct()
        setupFavoritesState(favoriteIDs: [])
        
        // When & Then
        XCTAssertFalse(sut.isFavorite(product))
    }
    
    // MARK: - Cart Tests
    
    func test_addToCart_whenSuccessful_shouldSaveToCoreData() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Cart operation completed")
        
        // When
        sut.addToCart(product)
        
        // Wait for the async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(mockCoreDataService.saveCartItemCalled)
        XCTAssertEqual(mockCoreDataService.savedCartProduct?.id, product.id)
    }
    
    func test_addToCart_whenSuccessful_shouldPostNotification() {
        // Given
        let product = createMockProduct()
        mockCoreDataService.shouldSucceed = true
        
        let expectation = XCTestExpectation(description: "Cart operation completed")
        
        // When
        sut.addToCart(product)
        
        // Wait for the async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertTrue(mockNotificationManager.postCalled)
        XCTAssertEqual(mockNotificationManager.postedNotificationName, .cartUpdated)
    }
    
    // MARK: - Refresh Tests
    
    func test_refreshData_shouldResetStateAndReload() {
        // Given
        let products = createMockProducts()
        mockProductService.mockProductsPage1 = products
        
        let expectation = XCTestExpectation(description: "Refresh completed")
        
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.refreshData { }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    
    func test_retryFetch_shouldReloadProducts() {
        // Given
        let expectation = XCTestExpectation(description: "Retry completed")
        let products = createMockProducts()
        mockProductService.mockProductsPage1 = products
        
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        
        // When
        sut.retryFetch()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.products.count, products.count)
    }
    
    // MARK: - Clear Filters Tests
    
    func test_clearAllFilters_shouldResetFilters() {
        // Given
        let products = createMockProducts()
        mockProductService.mockProductsPage1 = products
        
        let loadExpectation = XCTestExpectation(description: "Products loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                loadExpectation.fulfill()
            }
        }
        
        sut.fetchFirstPage()
        wait(for: [loadExpectation], timeout: 1.0)
        
        // Apply some filters first
        sut.setSearchText("iPhone")
        
        // When
        sut.clearAllFilters()
        
        // Then
        XCTAssertEqual(sut.filteredProducts.count, products.count)
    }
    
    
    // MARK: - Helper Methods
    
    private func setupFavoritesState(favoriteIDs: [String]) {
        mockCoreDataService.mockFavoriteIDs = favoriteIDs
        mockCoreDataService.shouldSucceed = true
        
        // Wait for favorites to load (they load in the initializer)
        let expectation = XCTestExpectation(description: "Favorites loaded")
        sut.onStateChange = { state in
            if case .loaded = state {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }
} 
