//
//  MainTabBarController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit
import Factory

final class MainTabBarController: UITabBarController {
    private let coreDataService: CoreDataServiceProtocol
    private let notificationManager: NotificationManagerProtocol
    private var cartObserver: NSObjectProtocol?
    
    init() {
        self.coreDataService = Container.shared.coreDataService()
        self.notificationManager = Container.shared.notificationManager()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.isTranslucent = false
        
        setupCartObserver()
        updateCartBadge()
    }
    
    deinit {
        if let observer = cartObserver {
            notificationManager.remove(observer: observer)
        }
    }
    
    private func setupCartObserver() {
        cartObserver = notificationManager.observe(name: .cartUpdated) { [weak self] _ in
            self?.updateCartBadge()
        }
    }
    
    private func updateCartBadge() {
        coreDataService.loadCartItems { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let products):
                    let totalItems = products.reduce(0) { sum, product in
                        return sum + Int(product.quantity ?? 0)
                    }
                    
                    // Update badge on cart tab (index 1)
                    if let tabBarItems = self.tabBar.items, tabBarItems.count > 1 {
                        let cartTabItem = tabBarItems[1]
                        if totalItems > 0 {
                            cartTabItem.badgeValue = "\(totalItems)"
                        } else {
                            cartTabItem.badgeValue = nil
                        }
                    }
                    
                case .failure:
                    // Clear badge on error
                    if let tabBarItems = self.tabBar.items, tabBarItems.count > 1 {
                        let cartTabItem = tabBarItems[1]
                        cartTabItem.badgeValue = nil
                    }
                }
            }
        }
    }
}
