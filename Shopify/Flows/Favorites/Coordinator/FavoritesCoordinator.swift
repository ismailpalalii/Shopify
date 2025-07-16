//
//  FavoritesCoordinator.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit
import Factory

final class FavoritesCoordinator: Coordinator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    
    func start() {
        let productService = Container.shared.productService()
        let coreDataService = Container.shared.coreDataService()
        let notificationManager = Container.shared.notificationManager()

        let favoritesViewModel = FavoritesViewModel(
            productService: productService,
            coreDataService: coreDataService,
            notificationManager: notificationManager
        )
        let favoritesViewController = FavoritesViewController(viewModel: favoritesViewModel)
        navigationController.setViewControllers([favoritesViewController], animated: false)
    }
} 
