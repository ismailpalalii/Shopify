//
//  AppCoordinator.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit

final class AppCoordinator {
    let window: UIWindow
    var tabBarCoordinator: TabBarCoordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let tabBarCoordinator = TabBarCoordinator()
        self.tabBarCoordinator = tabBarCoordinator
        let tabBarController = tabBarCoordinator.start()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
