//
//  FavoritesViewModel.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import Foundation

final class FavoritesViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(AppError)
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case (.loading, .loading):
                return true
            case (.loaded, .loaded):
                return true
            case (.empty, .empty):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    enum AppError: LocalizedError, Equatable {
        case networkUnavailable
        case serverError
        case invalidData
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .networkUnavailable:
                return "İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin."
            case .serverError:
                return "Sunucu hatası. Lütfen daha sonra tekrar deneyin."
            case .invalidData:
                return "Geçersiz veri. Lütfen uygulamayı yeniden başlatın."
            case .unknown(let error):
                return "Beklenmeyen hata: \(error.localizedDescription)"
            }
        }
        
        var canRetry: Bool {
            switch self {
            case .networkUnavailable, .serverError:
                return true
            case .invalidData, .unknown:
                return false
            }
        }
        
        static func == (lhs: AppError, rhs: AppError) -> Bool {
            switch (lhs, rhs) {
            case (.networkUnavailable, .networkUnavailable):
                return true
            case (.serverError, .serverError):
                return true
            case (.invalidData, .invalidData):
                return true
            case (.unknown(let lhsError), .unknown(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }

    private let productService: ProductServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private let notificationManager: NotificationManagerProtocol

    private(set) var favoriteProducts: [Product] = []
    private(set) var filteredProducts: [Product] = []
    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }

    private(set) var favoriteProductIDs: Set<String> = []
    private var searchText: String = ""

    var onStateChange: ((State) -> Void)?

    init(
        productService: ProductServiceProtocol,
        coreDataService: CoreDataServiceProtocol,
        notificationManager: NotificationManagerProtocol
    ) {
        self.productService = productService
        self.coreDataService = coreDataService
        self.notificationManager = notificationManager

        // Load favorite product IDs
        loadFavoriteProductIDs()
        
        // Observe cart updates
        notificationManager.observe(name: .cartUpdated) { [weak self] _ in
            // Refresh if needed
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
    
    func loadFavorites() {
        state = .loading
        onStateChange?(state)
        
        // Load favorite product IDs first
        coreDataService.loadFavoriteProductIDs { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let ids):
                self.favoriteProductIDs = Set(ids)
                
                if ids.isEmpty {
                    self.favoriteProducts = []
                    self.filteredProducts = []
                    self.state = .empty
                    self.onStateChange?(self.state)
                    return
                }
                
                // Fetch all products to get favorite ones
                self.productService.fetchAllProducts { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let allProducts):
                        // Filter only favorite products
                        self.favoriteProducts = allProducts.filter { self.favoriteProductIDs.contains($0.id) }
                        self.filterAndSortProducts()
                        
                    case .failure(let error):
                        self.state = .error(self.mapError(error))
                        self.onStateChange?(self.state)
                    }
                }
                
            case .failure:
                self.favoriteProducts = []
                self.filteredProducts = []
                self.state = .empty
                self.onStateChange?(self.state)
            }
        }
    }
    
    private func loadFavoriteProductIDs() {
        coreDataService.loadFavoriteProductIDs { [weak self] result in
            switch result {
            case .success(let ids):
                self?.favoriteProductIDs = Set(ids)
            case .failure:
                self?.favoriteProductIDs = []
            }
        }
    }
    
    private func mapError(_ error: Error) -> AppError {
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
    
    func retryFetch() {
        loadFavorites()
    }

    func setSearchText(_ text: String) {
        searchText = text
        filterAndSortProducts()
    }
    
    func clearAllFilters() {
        searchText = ""
        filterAndSortProducts()
    }

    private func filterAndSortProducts() {
        var filtered = favoriteProducts
        
        // Apply search filter
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lower = searchText.lowercased()
            filtered = filtered.filter { $0.name.lowercased().contains(lower) }
        }
        
        filteredProducts = filtered
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
                    // Remove from favorites list
                    self.favoriteProducts.removeAll { $0.id == product.id }
                    self.filteredProducts.removeAll { $0.id == product.id }
                    self.filterAndSortProducts()
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