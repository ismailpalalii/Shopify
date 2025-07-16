//
//  ProductListViewModel.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import Foundation

final class ProductListViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(AppError)
    }
    
    enum AppError: LocalizedError, Equatable {
        case networkUnavailable
        case serverError
        case invalidData
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .networkUnavailable:
                return "No internet connection. Please check your connection."
            case .serverError:
                return "Server error. Please try again later."
            case .invalidData:
                return "Invalid data. Please restart the app."
            case .unknown(let error):
                return "Unexpected error: \(error.localizedDescription)"
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
            case (.networkUnavailable, .networkUnavailable),
                 (.serverError, .serverError),
                 (.invalidData, .invalidData):
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
    private var filterData: FilterData = FilterData()
    
    // For filter data - cache all products to extract brands/models
    private var allProductsCache: [Product] = []
    private var isAllProductsCached = false

    var onStateChange: ((State) -> Void)?
    var onError: ((Error) -> Void)?
    var isFirstPage: Bool { currentPage == 1 }
    var isFilteringActive: Bool { 
        return !filterData.selectedBrands.isEmpty || !filterData.selectedModels.isEmpty || !searchText.isEmpty
    }

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
        
        // Clear all products cache when refreshing to start fresh
        allProductsCache = []
        isAllProductsCached = false
        
        fetchProducts(isInitial: true)
    }
    
    func refreshData(completion: @escaping () -> Void) {
        products = []
        filteredProducts = []
        currentPage = 1
        isLastPage = false
        
        // Clear all products cache when refreshing to start fresh
        allProductsCache = []
        isAllProductsCached = false
        
        fetchProducts(isInitial: true)
        completion()
    }

    func fetchNextPage() {
        guard !isFetching, !isLastPage else { 
            return 
        }
        currentPage += 1
        fetchProducts(isInitial: false)
    }

    private func fetchProducts(isInitial: Bool) {
        if isInitial { state = .loading }
        isFetching = true
        onStateChange?(state) // state is already current, trigger for spinner
        

        
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
                    self.filterAndSortProducts()
                }
            case .failure(let error):
                self.state = .error(self.mapError(error))
            }
            self.onStateChange?(self.state)
        }
    }
    
    private func mapError(_ error: Error) -> AppError {
        // Map different error types to user-friendly messages
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
        fetchProducts(isInitial: true)
    }

    func setSearchText(_ text: String) {
        searchText = text
        
        // If search is not empty and we don't have all products cached, fetch them first
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isAllProductsCached {
            fetchAllProductsForFilter { [weak self] in
                self?.filterAndSortProducts()
            }
        } else {
            filterAndSortProducts()
        }
    }
    
    func clearAllFilters() {
        filterData = FilterData()
        searchText = ""
        
        // Clear all products cache when clearing filters to return to pagination mode
        allProductsCache = []
        isAllProductsCached = false
        
        filterAndSortProducts()
    }
    
    func applyFilter(_ filter: FilterData) {
        filterData = filter
        filterAndSortProducts()
    }
    
    func getCurrentFilterData() -> FilterData {
        var currentFilterData = filterData
        
        // Use cached all products if available, otherwise use current products
        let productsToUse = isAllProductsCached ? allProductsCache : products
        
        // Extract unique brands and models from all products
        let uniqueBrands = Array(Set(productsToUse.map { $0.brand })).filter { !$0.isEmpty }.sorted()
        let uniqueModels = Array(Set(productsToUse.map { $0.model })).filter { !$0.isEmpty }.sorted()
        
        currentFilterData.availableBrands = uniqueBrands
        currentFilterData.availableModels = uniqueModels
        
        return currentFilterData
    }
    
    func fetchAllProductsForFilter(completion: @escaping () -> Void) {
        // If already cached, return immediately
        if isAllProductsCached {
            completion()
            return
        }
        
        // Fetch all products for filter/search purposes
        productService.fetchAllProducts { [weak self] result in
            switch result {
            case .success(let allProducts):
                self?.allProductsCache = allProducts
                self?.isAllProductsCached = true
                completion()
            case .failure:
                // If fails, use current products
                self?.isAllProductsCached = false
                completion()
            }
        }
    }

    private func filterAndSortProducts() {
        // Use all products if cached and any filter/search is active, otherwise use pagination products
        let productsToFilter = (isAllProductsCached && (isFilteringActive || !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)) ? allProductsCache : products
        var filtered = productsToFilter
        
        // Apply search filter
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lower = searchText.lowercased()
            filtered = filtered.filter { $0.name.lowercased().contains(lower) }
        }
        
        // Apply brand filter
        if !filterData.selectedBrands.isEmpty {
            filtered = filtered.filter { product in
                return filterData.selectedBrands.contains(product.brand)
            }
        }
        
        // Apply model filter
        if !filterData.selectedModels.isEmpty {
            filtered = filtered.filter { product in
                return filterData.selectedModels.contains(product.model)
            }
        }
        
        // Apply sorting
        switch filterData.sortOption {
        case .oldToNew:
            filtered = filtered.sorted { $0.createdAt < $1.createdAt }
        case .newToOld:
            filtered = filtered.sorted { $0.createdAt > $1.createdAt }
        case .priceHighToLow:
            filtered = filtered.sorted { 
                let price1 = extractPrice(from: $0.price)
                let price2 = extractPrice(from: $1.price)
                return price1 > price2
            }
        case .priceLowToHigh:
            filtered = filtered.sorted { 
                let price1 = extractPrice(from: $0.price)
                let price2 = extractPrice(from: $1.price)
                return price1 < price2
            }
        }
        
        filteredProducts = filtered
        state = filteredProducts.isEmpty ? .empty : .loaded
        onStateChange?(state)
    }
    
    private func extractPrice(from priceString: String) -> Double {
        // Remove common currency symbols and separators
        let cleanedString = priceString
            .replacingOccurrences(of: "₺", with: "")
            .replacingOccurrences(of: "TL", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Double(cleanedString) ?? 0
    }

    func addToCart(_ product: Product, quantity: Int16 = 1) {
        coreDataService.saveCartItem(product, quantity: quantity) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.notificationManager.post(name: .cartUpdated, object: nil)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.onError?(error)
                }
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
