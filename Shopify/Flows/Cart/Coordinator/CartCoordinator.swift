//
//  CartCoordinator.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit
import Factory

final class CartCoordinator: Coordinator {
    let navigationController: UINavigationController
    private var productDetailCoordinator: ProductDetailCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let coreDataService = Container.shared.coreDataService()
        let notificationManager = Container.shared.notificationManager()

        let viewModel = CartViewModel(coreDataService: coreDataService, notificationManager: notificationManager)
        let cartVC = CartViewController(viewModel: viewModel)
        cartVC.coordinator = self
        navigationController.setViewControllers([cartVC], animated: false)
    }
    
    // MARK: - Navigation Methods
    func showProductDetail(for product: Product) {
        let productDetailCoordinator = ProductDetailCoordinator(navigationController: navigationController)
        self.productDetailCoordinator = productDetailCoordinator
        productDetailCoordinator.showProductDetail(for: product)
    }
}
