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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }


    func start() {
        let coreDataService = Container.shared.coreDataService()
        let notificationManager = Container.shared.notificationManager()

        let viewModel = CartViewModel(coreDataService: coreDataService, notificationManager: notificationManager)
        let cartVC = CartViewController(viewModel: viewModel)
        navigationController.setViewControllers([cartVC], animated: false)
    }
}
