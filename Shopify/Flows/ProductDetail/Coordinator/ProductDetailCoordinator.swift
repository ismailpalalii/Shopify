//
//  ProductDetailCoordinator.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit
import Factory

final class ProductDetailCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {}
    
    func showProductDetail(for product: Product) {
        let detailVM = ProductDetailViewModel(
            product: product,
            productService: Container.shared.productService(),
            coreDataService: Container.shared.coreDataService(),
            notificationManager: Container.shared.notificationManager()
        )
        let detailVC = ProductDetailViewController(viewModel: detailVM)
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
    }
} 
