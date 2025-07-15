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
        case loaded
        case empty
        case error(Error)
    }

    private let productService: ProductServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private let notificationManager: NotificationManagerProtocol

    private(set) var products: [Product] = []
    private(set) var filteredProducts: [Product] = []
    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }
    private var currentPage = 1
    private let pageLimit = 4
    private(set) var isLastPage = false
    private(set) var isFetching = false

    private(set) var favoriteProductIDs: Set<String> = []
    private var searchText: String = ""

    var onStateChange: ((State) -> Void)?
    var isFirstPage: Bool { currentPage == 1 }

    init(
        productService: ProductServiceProtocol,
        coreDataService: CoreDataServiceProtocol,
        notificationManager: NotificationManagerProtocol
    ) {
        self.productService = productService
        self.coreDataService = coreDataService
        self.notificationManager = notificationManager

        coreDataService.loadFavoriteProductIDs { [weak self] result in
            switch result {
            case .success(let ids):
                self?.favoriteProductIDs = Set(ids)
                self?.onStateChange?(.loaded)
            case .failure:
                self?.favoriteProductIDs = []
            }
        }
    }

    func makeProductDetailViewModel(for product: Product) -> ProductDetailViewModel {
        return ProductDetailViewModel(
            product: product,
            productService: self.productService,
            coreDataService: self.coreDataService,
            notificationManager: self.notificationManager
        )
    }
    
    func fetchFirstPage() {
        products = []
        filteredProducts = []
        currentPage = 1
        isLastPage = false
        fetchProducts(isInitial: true)
    }

    func fetchNextPage() {
        guard !isFetching, !isLastPage else { return }
        currentPage += 1
        fetchProducts(isInitial: false)
    }

    private func fetchProducts(isInitial: Bool) {
        if isInitial { state = .loading }
        isFetching = true
        onStateChange?(state) // state zaten güncel, spinner için tetikleyelim
        productService.fetchProducts(page: currentPage, limit: pageLimit) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            switch result {
            case .success(let newProducts):
                if newProducts.isEmpty {
                    self.isLastPage = true
                    self.state = self.products.isEmpty ? .empty : .loaded
                } else {
                    self.products.append(contentsOf: newProducts)
                    self.filterProducts(with: self.searchText)
                }
            case .failure(let error):
                self.state = .error(error)
            }
            self.onStateChange?(self.state)
        }
    }

    func setSearchText(_ text: String) {
        searchText = text
        filterProducts(with: text)
    }

    private func filterProducts(with text: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredProducts = products
        } else {
            let lower = text.lowercased()
            filteredProducts = products.filter { $0.name.lowercased().contains(lower) }
        }
        state = filteredProducts.isEmpty ? .empty : .loaded
        onStateChange?(state)
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

    func isFavorite(_ product: Product) -> Bool {
        favoriteProductIDs.contains(product.id)
    }

    func toggleFavorite(_ product: Product, completion: (() -> Void)? = nil) {
        if isFavorite(product) {
            coreDataService.removeFavoriteProductID(product.id) { [weak self] result in
                guard let self = self else { return }
                if case .success = result {
                    self.favoriteProductIDs.remove(product.id)
                    completion?()
                }
            }
        } else {
            coreDataService.saveFavoriteProductID(product.id) { [weak self] result in
                guard let self = self else { return }
                if case .success = result {
                    self.favoriteProductIDs.insert(product.id)
                    completion?()
                }
            }
        }
    }
}
