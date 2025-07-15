//
//  ProductListCoordinator.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit
import Factory

final class ProductListCoordinator: Coordinator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let productService = Container.shared.productService()
        let coreDataService = Container.shared.coreDataService()
        let notificationManager = Container.shared.notificationManager()

        let viewModel = ProductListViewModel(
            productService: productService,
            coreDataService: coreDataService,
            notificationManager: notificationManager
        )

        let productListVC = ProductListViewController(viewModel: viewModel)
        navigationController.setViewControllers([productListVC], animated: false)
    }
}
