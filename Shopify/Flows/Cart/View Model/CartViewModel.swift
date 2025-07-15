//
//  CartViewModel.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


final class CartViewModel {
    private let coreDataService: CoreDataServiceProtocol
    private let notificationManager: NotificationManagerProtocol

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

    private func observeCartChanges() {
        _ = notificationManager.observe(name: .cartUpdated) { [weak self] _ in
            self?.loadCartItems()
        }
    }

    func loadCartItems() {
        coreDataService.loadCartItems { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let products):
                var mergedProducts: [String: Product] = [:]
                for product in products {
                    if let existing = mergedProducts[product.id] {
                        var updatedProduct = existing
                        updatedProduct.quantity! += product.quantity ?? 0
                        mergedProducts[product.id] = updatedProduct
                    } else {
                        mergedProducts[product.id] = product
                    }
                }
                self.cartItems = Array(mergedProducts.values)
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
                self.cartItems[index] = item
                self.calculateTotalPrice()
                self.onCartItemsChanged?(self.cartItems)
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
                self.cartItems.removeAll(where: { $0.id == product.id })
                self.calculateTotalPrice()
                self.onCartItemsChanged?(self.cartItems)
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
                self.cartItems.removeAll()
                self.calculateTotalPrice()
                self.onCartItemsChanged?(self.cartItems)
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
}
