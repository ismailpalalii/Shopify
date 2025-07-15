//
//  ProductListViewModel.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation

final class ProductListViewModel {
    enum State {
        case idle
        case loading
        case loaded([Product])
        case empty
        case error(Error)
    }

    private let productService: ProductServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private let notificationManager: NotificationManagerProtocol

    private(set) var products: [Product] = []
    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }
    private var currentPage = 1
    private let pageLimit = 4
    private var isLastPage = false
    private var isFetching = false

    var onStateChange: ((State) -> Void)?

    init(
        productService: ProductServiceProtocol,
        coreDataService: CoreDataServiceProtocol,
        notificationManager: NotificationManagerProtocol
    ) {
        self.productService = productService
        self.coreDataService = coreDataService
        self.notificationManager = notificationManager
    }

    func fetchFirstPage() {
        products = []
        currentPage = 1
        isLastPage = false
        fetchProducts()
    }

    func fetchNextPage() {
        guard !isFetching, !isLastPage else { return }
        currentPage += 1
        fetchProducts()
    }

    private func fetchProducts() {
        state = .loading
        isFetching = true
        productService.fetchProducts(page: currentPage, limit: pageLimit) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            switch result {
            case .success(let newProducts):
                if newProducts.isEmpty {
                    self.isLastPage = true
                    self.state = self.products.isEmpty ? .empty : .loaded(self.products)
                } else {
                    self.products.append(contentsOf: newProducts)
                    self.state = .loaded(self.products)
                }
            case .failure(let error):
                self.state = .error(error)
            }
        }
    }

    // MARK: - Cart actions

    func addToCart(_ product: Product) {
        coreDataService.saveCartItem(product) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.notificationManager.post(name: .cartUpdated, object: nil)
            case .failure(let error):
                // Optional: handle error UI
                print("Cart add error: \(error)")
            }
        }
    }
}
