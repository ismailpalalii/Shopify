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
    private var productDetailCoordinator: ProductDetailCoordinator?

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
        favoritesViewController.coordinator = self
        navigationController.setViewControllers([favoritesViewController], animated: false)
    }
    
    // MARK: - Navigation Methods
    func showProductDetail(for product: Product) {
        let productDetailCoordinator = ProductDetailCoordinator(navigationController: navigationController)
        self.productDetailCoordinator = productDetailCoordinator
        productDetailCoordinator.showProductDetail(for: product)
    }
} 
