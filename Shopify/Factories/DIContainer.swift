//
//  DIContainer.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation
import Factory

protocol DependencyContainerProtocol {
    func networkManager() -> NetworkManagerProtocol
    func coreDataService() -> CoreDataServiceProtocol
    func productService() -> ProductServiceProtocol
    func notificationManager() -> NotificationManagerProtocol
}

final class DIContainer: DependencyContainerProtocol {
    static let shared = DIContainer()
    
    private let _networkManager: NetworkManagerProtocol
    private let _coreDataService: CoreDataServiceProtocol
    private let _productService: ProductServiceProtocol
    private let _notificationManager: NotificationManagerProtocol
    
    init(
        networkManager: NetworkManagerProtocol? = nil,
        coreDataService: CoreDataServiceProtocol? = nil,
        notificationManager: NotificationManagerProtocol? = nil,
        productService: ProductServiceProtocol? =  nil
    ) {
        self._networkManager = networkManager ?? NetworkManagerImpl()
        self._coreDataService = coreDataService ?? CoreDataServiceImpl()
        self._notificationManager = notificationManager ?? NotificationManagerImpl()
        self._productService = productService ?? ProductServiceImpl(networkManager: self._networkManager)
    }
    
    func networkManager() -> NetworkManagerProtocol {
        return _networkManager
    }
    
    func coreDataService() -> CoreDataServiceProtocol {
        return _coreDataService
    }
    
    func productService() -> ProductServiceProtocol {
        return _productService
    }
    
    func notificationManager() -> NotificationManagerProtocol {
        return _notificationManager
    }
}

// Legacy Factory support - will be removed gradually
extension Container {
    var networkManager: Factory<NetworkManagerProtocol> {
        Factory(self) { DIContainer.shared.networkManager() }
    }
    var coreDataService: Factory<CoreDataServiceProtocol> {
        Factory(self) { DIContainer.shared.coreDataService() }
    }
    var productService: Factory<ProductServiceProtocol> {
        Factory(self) { DIContainer.shared.productService() }
    }
    var notificationManager: Factory<NotificationManagerProtocol> {
        Factory(self) { DIContainer.shared.notificationManager() }
    }
}
