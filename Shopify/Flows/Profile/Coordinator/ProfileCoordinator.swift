//
//  ProfileCoordinator.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit

final class ProfileCoordinator: Coordinator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let profileViewModel = ProfileViewModel()
        let profileViewController = ProfileViewController(viewModel: profileViewModel)
        navigationController.setViewControllers([profileViewController], animated: false)
    }
} 