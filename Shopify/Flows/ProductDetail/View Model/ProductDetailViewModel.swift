//
//  ProductDetailViewModel.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation

final class ProductDetailViewModel {
    private let productService: ProductServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private let notificationManager: NotificationManagerProtocol

    private(set) var product: Product

    private(set) var isFavorite: Bool = false {
        didSet { onFavoriteStatusChange?(isFavorite) }
    }

    var onFavoriteStatusChange: ((Bool) -> Void)?
    var onCartAdded: (() -> Void)?
    var onError: ((Error) -> Void)?

    init(
        product: Product,
        productService: ProductServiceProtocol,
        coreDataService: CoreDataServiceProtocol,
        notificationManager: NotificationManagerProtocol
    ) {
        self.product = product
        self.productService = productService
        self.coreDataService = coreDataService
        self.notificationManager = notificationManager

        loadFavoriteStatus()
    }

    private func loadFavoriteStatus() {
        coreDataService.loadFavoriteProductIDs { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let ids):
                self.isFavorite = ids.contains(self.product.id)
            case .failure:
                self.isFavorite = false
            }
        }
    }

    func toggleFavorite() {
        if isFavorite {
            coreDataService.removeFavoriteProductID(product.id) { [weak self] result in
                guard let self = self else { return }
                if case .success = result {
                    self.isFavorite = false
                } else if case .failure(let error) = result {
                    self.onError?(error)
                }
            }
        } else {
            coreDataService.saveFavoriteProductID(product.id) { [weak self] result in
                guard let self = self else { return }
                if case .success = result {
                    self.isFavorite = true
                } else if case .failure(let error) = result {
                    self.onError?(error)
                }
            }
        }
    }

    func addToCart(_ product: Product, quantity: Int16 = 1) {
        coreDataService.saveCartItem(product, quantity: quantity) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.notificationManager.post(name: .cartUpdated, object: nil)
            case .failure(let error):
                print("Cart add error: \(error)")
            }
        }
    }
}
