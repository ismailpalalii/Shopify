//
//  DIContainer.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation
import Factory

final class DIContainer {
    static let shared = DIContainer()
    private init() {
        registerDependencies()
    }

    private func registerDependencies() {
        Container.shared.networkManager.register {
            NetworkManagerImpl()
        }
        Container.shared.coreDataService.register {
            CoreDataServiceImpl()
        }
        Container.shared.productService.register {
            ProductServiceImpl(networkManager: Container.shared.networkManager())
        }
    }
}

// Dependency keys
extension Container {
    var networkManager: Factory<NetworkManagerProtocol> {
        Factory(self) { fatalError("Dependency not registered!") }
    }
    var coreDataService: Factory<CoreDataServiceProtocol> {
        Factory(self) { fatalError("Dependency not registered!") }
    }
    var productService: Factory<ProductServiceProtocol> {
        Factory(self) { fatalError("Dependency not registered!") }
    }
}