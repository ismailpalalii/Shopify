//
//  CartViewModel.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import Foundation
import Factory

final class CartViewModel {
    private let coreDataService: CoreDataServiceProtocol
    private let notificationManager: NotificationManagerProtocol
    private var cartObserver: NSObjectProtocol?

    private(set) var cartItems: [Product] = [] {
        didSet { onCartItemsChanged?(cartItems) }
    }
    
    private(set) var totalPrice: Double = 0.0 {
        didSet { onTotalPriceChanged?(totalPrice) }
    }
    
    var onCartItemsChanged: (([Product]) -> Void)?
    var onTotalPriceChanged: ((Double) -> Void)?
    var onError: ((Error) -> Void)?

    init(coreDataService: CoreDataServiceProtocol, notificationManager: NotificationManagerProtocol) {
        self.coreDataService = coreDataService
        self.notificationManager = notificationManager
        
        observeCartChanges()
    }
    
    deinit {
        if let observer = cartObserver {
            notificationManager.remove(observer: observer)
        }
    }

    private func observeCartChanges() {
        cartObserver = notificationManager.observe(name: .cartUpdated) { [weak self] _ in
            self?.loadCartItems()
        }
    }

    func loadCartItems() {
        coreDataService.loadCartItems { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let products):
                // Preserve order by keeping existing items and updating quantities
                var newCartItems: [Product] = []
                var processedIds: Set<String> = []
                
                // First, update existing items in their current positions
                for existingItem in self.cartItems {
                    if let foundProduct = products.first(where: { $0.id == existingItem.id }) {
                        // Calculate total quantity for this product
                        let totalQuantity = products.filter { $0.id == existingItem.id }
                            .reduce(0) { $0 + ($1.quantity ?? 0) }
                        
                        var updatedItem = existingItem
                        updatedItem.quantity = totalQuantity
                        
                        if totalQuantity > 0 {
                            newCartItems.append(updatedItem)
                        }
                        processedIds.insert(existingItem.id)
                    }
                }
                
                // Then, add new items that weren't in the cart before
                for product in products {
                    if !processedIds.contains(product.id) {
                        // Calculate total quantity for this new product
                        let totalQuantity = products.filter { $0.id == product.id }
                            .reduce(0) { $0 + ($1.quantity ?? 0) }
                        
                        if totalQuantity > 0 {
                            var newProduct = product
                            newProduct.quantity = totalQuantity
                            newCartItems.append(newProduct)
                            processedIds.insert(product.id)
                        }
                    }
                }
                
                self.cartItems = newCartItems
                self.calculateTotalPrice()
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    func increaseQuantity(for product: Product) {
        updateQuantity(for: product, change: 1)
    }

    func decreaseQuantity(for product: Product) {
        guard let index = cartItems.firstIndex(where: { $0.id == product.id }),
              let currentQuantity = cartItems[index].quantity else { return }

        if currentQuantity <= 1 {
            removeItem(product)
        } else {
            updateQuantity(for: product, change: -1)
        }
    }
    
    private func updateQuantity(for product: Product, change: Int16) {
        guard let index = cartItems.firstIndex(where: { $0.id == product.id }) else { return }
        var item = cartItems[index]
        let currentQuantity = item.quantity ?? 0
        let newQuantity = max(1, currentQuantity + change)
        item.quantity = newQuantity

        coreDataService.updateCartItem(item, quantity: newQuantity) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.notificationManager.post(name: .cartUpdated, object: nil)
            case .failure(let error):
                self.onError?(error)
            }
        }
    }

    func removeItem(_ product: Product) {
        coreDataService.removeCartItem(product) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.notificationManager.post(name: .cartUpdated, object: nil)
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    func clearCart() {
        coreDataService.clearCart { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.notificationManager.post(name: .cartUpdated, object: nil)
            case .failure(let error):
                self.onError?(error)
            }
        }
    }
    
    private func calculateTotalPrice() {
        totalPrice = cartItems.reduce(0.0) { total, product in
            let price = Double(product.price) ?? 0
            let quantity = Double(product.quantity ?? 1)
            return total + (price * quantity)
        }
    }
    
    func makeProductDetailViewModel(for product: Product) -> ProductDetailViewModel {
        return ProductDetailViewModel(
            product: product,
            productService: Container.shared.productService(),
            coreDataService: coreDataService,
            notificationManager: notificationManager
        )
    }
}
