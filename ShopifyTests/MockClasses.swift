//
//  MockClasses.swift
//  ShopifyTests
//
//  Created by İsmail Palalı on 15.07.2025.
//

import Foundation
import XCTest
@testable import Shopify

// MARK: - Mock Product Service

class MockProductService: ProductServiceProtocol {
    var mockProductsPage1: [Product] = []
    var mockProductsPage2: [Product] = []
    var shouldFail = false
    var mockError: Error?
    
    func fetchProducts(page: Int, limit: Int, completion: @escaping (Result<[Product], Error>) -> Void) {
        DispatchQueue.main.async {
            if self.shouldFail {
                completion(.failure(self.mockError ?? URLError(.unknown)))
            } else {
                let productsToReturn: [Product]
                switch page {
                case 1:
                    productsToReturn = self.mockProductsPage1
                case 2:
                    productsToReturn = self.mockProductsPage2
                default:
                    productsToReturn = []
                }
                
                completion(.success(productsToReturn))
            }
        }
    }
    
    func fetchAllProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        DispatchQueue.main.async {
            if self.shouldFail {
                completion(.failure(self.mockError ?? URLError(.unknown)))
            } else {
                let allProducts = self.mockProductsPage1 + self.mockProductsPage2
                completion(.success(allProducts))
            }
        }
    }
    
    func reset() {
        mockProductsPage1 = []
        mockProductsPage2 = []
        shouldFail = false
        mockError = nil
    }
}

// MARK: - Mock Core Data Service

class MockCoreDataService: CoreDataServiceProtocol {
    var shouldSucceed = true
    var mockError: Error?
    var saveCartItemCalled = false
    var savedCartProduct: Product?
    var saveFavoriteProductIDCalled = false
    var savedProductID: String?
    var removeFavoriteProductIDCalled = false
    var removedProductID: String?
    var removedCartProduct: Product?
    var updateCartItemQuantityCalled = false
    var removeCartItemCalled = false
    var clearCartCalled = false
    var mockFavoriteIDs: [String] = []
    var mockCartProducts: [Product] = []
    
    func saveCartItem(_ product: Product, quantity: Int16, completion: @escaping (Result<Void, Error>) -> Void) {
        saveCartItemCalled = true
        savedCartProduct = product
        
        DispatchQueue.main.async {
            if self.shouldSucceed {
                completion(.success(()))
            } else {
                completion(.failure(self.mockError ?? CoreDataServiceError.saveFailed(NSError(domain: "TestError", code: -1, userInfo: nil))))
            }
        }
    }
    
    func loadCartItems(completion: @escaping (Result<[Product], Error>) -> Void) {
        if shouldSucceed {
            completion(.success(mockCartProducts))
        } else {
            completion(.failure(mockError ?? CoreDataServiceError.fetchFailed(NSError(domain: "TestError", code: -1, userInfo: nil))))
        }
    }
    
    func saveFavoriteProductID(_ productID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        saveFavoriteProductIDCalled = true
        savedProductID = productID
        
        DispatchQueue.main.async {
            if self.shouldSucceed {
                completion(.success(()))
            } else {
                completion(.failure(self.mockError ?? CoreDataServiceError.saveFailed(NSError(domain: "TestError", code: -1, userInfo: nil))))
            }
        }
    }
    
    func removeFavoriteProductID(_ productID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        removeFavoriteProductIDCalled = true
        removedProductID = productID
        
        DispatchQueue.main.async {
            if self.shouldSucceed {
                completion(.success(()))
            } else {
                completion(.failure(self.mockError ?? CoreDataServiceError.deleteFailed(NSError(domain: "TestError", code: -1, userInfo: nil))))
            }
        }
    }
    
    func loadFavoriteProductIDs(completion: @escaping (Result<[String], Error>) -> Void) {
        DispatchQueue.main.async {
            if self.shouldSucceed {
                completion(.success(self.mockFavoriteIDs))
            } else {
                completion(.failure(self.mockError ?? CoreDataServiceError.fetchFailed(NSError(domain: "TestError", code: -1, userInfo: nil))))
            }
        }
    }
    
    func updateCartItem(_ product: Product, quantity: Int16, completion: @escaping (Result<Void, Error>) -> Void) {
        updateCartItemQuantityCalled = true
        
        if shouldSucceed {
            completion(.success(()))
        } else {
            completion(.failure(mockError ?? CoreDataServiceError.updateFailed(NSError(domain: "TestError", code: -1, userInfo: nil))))
        }
    }
    
    func removeCartItem(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
        removeCartItemCalled = true
        removedCartProduct = product
        
        if shouldSucceed {
            completion(.success(()))
        } else {
            completion(.failure(mockError ?? CoreDataServiceError.deleteFailed(NSError(domain: "TestError", code: -1, userInfo: nil))))
        }
    }
    
    func clearCart(completion: @escaping (Result<Void, Error>) -> Void) {
        clearCartCalled = true
        
        if shouldSucceed {
            completion(.success(()))
        } else {
            completion(.failure(mockError ?? CoreDataServiceError.deleteFailed(NSError(domain: "TestError", code: -1, userInfo: nil))))
        }
    }
    
    func reset() {
        shouldSucceed = true
        mockError = nil
        saveCartItemCalled = false
        savedCartProduct = nil
        saveFavoriteProductIDCalled = false
        savedProductID = nil
        removeFavoriteProductIDCalled = false
        removedProductID = nil
        removedCartProduct = nil
        updateCartItemQuantityCalled = false
        removeCartItemCalled = false
        clearCartCalled = false
        mockFavoriteIDs = []
        mockCartProducts = []
    }
}

// MARK: - Mock Notification Manager

class MockNotificationManager: NotificationManagerProtocol {
    var postCalled = false
    var postedNotificationName: Notification.Name?
    var observeCalled = false
    var observedNotificationName: Notification.Name?
    var removeObserverCalled = false
    var removedObserver: Any?
    
    func post(name: Notification.Name, object: Any?) {
        postCalled = true
        postedNotificationName = name
    }
    
    func observe(name: Notification.Name, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        observeCalled = true
        observedNotificationName = name
        return NSObject()
    }
    
    func remove(observer: Any) {
        removeObserverCalled = true
        removedObserver = observer
    }
    
    func reset() {
        postCalled = false
        postedNotificationName = nil
        observeCalled = false
        observedNotificationName = nil
        removeObserverCalled = false
        removedObserver = nil
    }
}

// MARK: - Test Helper Extensions

extension XCTestCase {
    func createMockProduct() -> Product {
        return Product(
            id: "1",
            createdAt: "2024-01-01",
            name: "iPhone 15 Pro",
            image: "https://example.com/iphone.jpg",
            price: "999.99 ₺",
            description: "Latest iPhone model",
            model: "iPhone 15",
            brand: "Apple"
        )
    }
    
    func createMockProducts() -> [Product] {
        return [
            Product(id: "1", createdAt: "2024-01-01", name: "iPhone 15 Pro", image: "https://example.com/iphone.jpg", price: "999.99 ₺", description: "Latest iPhone", model: "iPhone 15", brand: "Apple"),
            Product(id: "2", createdAt: "2024-01-02", name: "Samsung Galaxy S24", image: "https://example.com/samsung.jpg", price: "899.99 ₺", description: "Latest Samsung", model: "Galaxy S24", brand: "Samsung"),
            Product(id: "3", createdAt: "2024-01-03", name: "MacBook Pro", image: "https://example.com/macbook.jpg", price: "1999.99 ₺", description: "Professional laptop", model: "MacBook Pro", brand: "Apple"),
            Product(id: "4", createdAt: "2024-01-04", name: "iPad Pro", image: "https://example.com/ipad.jpg", price: "1299.99 ₺", description: "Professional tablet", model: "iPad Pro", brand: "Apple")
        ]
    }
    
    func createMockProductsForNextPage() -> [Product] {
        return [
            Product(id: "5", createdAt: "2024-01-05", name: "Sony WH-1000XM5", image: "https://example.com/sony.jpg", price: "599.99 ₺", description: "Premium headphones", model: "WH-1000XM5", brand: "Sony"),
            Product(id: "6", createdAt: "2024-01-06", name: "Dell XPS 13", image: "https://example.com/dell.jpg", price: "1799.99 ₺", description: "Ultrabook laptop", model: "XPS 13", brand: "Dell"),
            Product(id: "7", createdAt: "2024-01-07", name: "AirPods Pro", image: "https://example.com/airpods.jpg", price: "299.99 ₺", description: "Wireless earbuds", model: "AirPods Pro", brand: "Apple"),
            Product(id: "8", createdAt: "2024-01-08", name: "Google Pixel 8", image: "https://example.com/pixel.jpg", price: "799.99 ₺", description: "Android flagship", model: "Pixel 8", brand: "Google")
        ]
    }
    
    func createMockCartProducts() -> [Product] {
        return [
            Product(id: "1", createdAt: "2024-01-01", name: "iPhone 15 Pro", image: "https://example.com/iphone.jpg", price: "999.99 ₺", description: "Latest iPhone", model: "iPhone 15", brand: "Apple"),
            Product(id: "2", createdAt: "2024-01-02", name: "Samsung Galaxy S24", image: "https://example.com/samsung.jpg", price: "899.99 ₺", description: "Latest Samsung", model: "Galaxy S24", brand: "Samsung")
        ]
    }
} 