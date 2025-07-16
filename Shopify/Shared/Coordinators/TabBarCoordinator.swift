//
//  TabBarCoordinator.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//
import UIKit

final class TabBarCoordinator {
    private var childCoordinators: [Coordinator] = []
    
    func start() -> UITabBarController {
        let tabBarController = MainTabBarController()
        
        // Home (Product List)
        let homeNav = UINavigationController()
        let productListCoordinator = ProductListCoordinator(navigationController: homeNav)
        productListCoordinator.start()
        childCoordinators.append(productListCoordinator)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        // Cart
        let cartNav = UINavigationController()
        let cartCoordinator = CartCoordinator(navigationController: cartNav)
        cartCoordinator.start()
        childCoordinators.append(cartCoordinator)
        cartNav.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 1)
        
        // Favorites
        let favNav = UINavigationController()
        let favoritesCoordinator = FavoritesCoordinator(navigationController: favNav)
        favoritesCoordinator.start()
        childCoordinators.append(favoritesCoordinator)
        favNav.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star"), tag: 2)
        
        // Profile
        let profileNav = UINavigationController()
        let profileCoordinator = ProfileCoordinator(navigationController: profileNav)
        profileCoordinator.start()
        childCoordinators.append(profileCoordinator)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
        
        tabBarController.viewControllers = [homeNav, cartNav, favNav, profileNav]
        return tabBarController
    }
    
    func childDidFinish(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}
