//
//  CoreDataServiceImpl.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation
import CoreData
import UIKit

final class CoreDataServiceImpl: CoreDataServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }

    func saveCartItem(_ product: Product) {
        // Implementation goes here
    }

    func removeCartItem(_ product: Product) {
        // Implementation goes here
    }

    func loadCartItems() -> [Product] {
        // Implementation goes here
        return []
    }

    func updateCartItem(_ product: Product) {
        // Implementation goes here
    }
}