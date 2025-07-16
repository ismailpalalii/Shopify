//
//  CoreDataServiceImpl.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation
import CoreData
import UIKit

enum CoreDataServiceError: Error {
    case entityNotFound
    case saveFailed(Error)
    case fetchFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
}

final class CoreDataServiceImpl: CoreDataServiceProtocol {
    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    init(context: NSManagedObjectContext? = nil) {
        if let providedContext = context {
            self.context = providedContext
        } else {
            // Safely get AppDelegate
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                fatalError("Could not get AppDelegate")
            }
            self.context = appDelegate.persistentContainer.viewContext
        }
        
        // Create background context for heavy operations
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.parent = self.context
    }

    func saveCartItem(_ product: Product, quantity: Int16 = 1, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CartItem")
            fetchRequest.predicate = NSPredicate(format: "id == %@", product.id)
            
            do {
                let results = try self.context.fetch(fetchRequest)
                if let existingItem = results.first {
                    let currentQuantity = existingItem.value(forKey: "quantity") as? Int16 ?? 0
                    existingItem.setValue(currentQuantity + quantity, forKey: "quantity")
                } else {
                    guard let entity = NSEntityDescription.entity(forEntityName: "CartItem", in: self.context) else {
                        completion(.failure(CoreDataServiceError.entityNotFound))
                        return
                    }
                    let cartItem = NSManagedObject(entity: entity, insertInto: self.context)
                    var productWithQuantity = product
                    productWithQuantity.quantity = quantity
                    cartItem.updateWithProduct(productWithQuantity)
                }
                try self.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(CoreDataServiceError.saveFailed(error)))
            }
        }
    }

        func updateCartItem(_ product: Product, quantity: Int16, completion: @escaping (Result<Void, Error>) -> Void) {
            context.perform {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CartItem")
                fetchRequest.predicate = NSPredicate(format: "id == %@", product.id)
                do {
                    if let results = try self.context.fetch(fetchRequest) as? [NSManagedObject], let cartItem = results.first {
                        cartItem.setValue(quantity, forKey: "quantity")
                        try self.context.save()
                        completion(.success(()))
                    } else {
                        completion(.failure(CoreDataServiceError.entityNotFound))
                    }
                } catch {
                    completion(.failure(CoreDataServiceError.updateFailed(error)))
                }
            }
        }

        func loadCartItems(completion: @escaping (Result<[Product], Error>) -> Void) {
            backgroundContext.perform {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CartItem")
                do {
                    let items = try self.backgroundContext.fetch(fetchRequest)
                    let products = items.compactMap { $0.toProduct() }
                    DispatchQueue.main.async {
                        completion(.success(products))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(CoreDataServiceError.fetchFailed(error)))
                    }
                }
            }
        }
        
        func removeCartItem(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void) {
            context.perform {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CartItem")
                fetchRequest.predicate = NSPredicate(format: "id == %@", product.id)
                do {
                    if let results = try self.context.fetch(fetchRequest) as? [NSManagedObject], let cartItem = results.first {
                        self.context.delete(cartItem)
                        try self.context.save()
                        completion(.success(()))
                    } else {
                        // no product, normal case
                        completion(.success(()))
                    }
                } catch {
                    completion(.failure(CoreDataServiceError.deleteFailed(error)))
                }
            }
        }
    
    func clearCart(completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CartItem")
            
            do {
                let cartItems = try self.context.fetch(fetchRequest)
                for item in cartItems {
                    self.context.delete(item)
                }
                try self.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(CoreDataServiceError.deleteFailed(error)))
            }
        }
    }
    
    func saveFavoriteProductID(_ id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteProduct", in: self.context) else {
                completion(.failure(CoreDataServiceError.entityNotFound))
                return
            }
            let fav = NSManagedObject(entity: entity, insertInto: self.context)
            fav.setValue(id, forKey: "id")
            do {
                try self.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(CoreDataServiceError.saveFailed(error)))
            }
        }
    }

    func removeFavoriteProductID(_ id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteProduct")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            do {
                if let results = try self.context.fetch(fetchRequest) as? [NSManagedObject], let fav = results.first {
                    self.context.delete(fav)
                    try self.context.save()
                    completion(.success(()))
                } else {
                    completion(.failure(CoreDataServiceError.entityNotFound))
                }
            } catch {
                completion(.failure(CoreDataServiceError.deleteFailed(error)))
            }
        }
    }

    func loadFavoriteProductIDs(completion: @escaping (Result<[String], Error>) -> Void) {
        backgroundContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteProduct")
            do {
                let items = try self.backgroundContext.fetch(fetchRequest)
                let ids = items.compactMap { $0.value(forKey: "id") as? String }
                DispatchQueue.main.async {
                    completion(.success(ids))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(CoreDataServiceError.fetchFailed(error)))
                }
            }
        }
    }
}

// MARK: - NSManagedObject Extensions
extension NSManagedObject {
    func toProduct() -> Product? {
        guard
            let id = value(forKey: "id") as? String,
            let name = value(forKey: "name") as? String,
            let price = value(forKey: "price") as? String,
            let image = value(forKey: "image") as? String
        else { return nil }
        
        let quantity = value(forKey: "quantity") as? Int16 ?? 0
        let brand = value(forKey: "brand") as? String ?? ""
        let model = value(forKey: "model") as? String ?? ""
        let description = value(forKey: "productDescription") as? String ?? ""
        
        return Product(
            id: id,
            createdAt: "",
            name: name,
            image: image,
            price: price,
            description: description,
            model: model,
            brand: brand,
            quantity: quantity
        )
    }
    
    func updateWithProduct(_ product: Product) {
        setValue(product.id, forKey: "id")
        setValue(product.name, forKey: "name")
        setValue(product.price, forKey: "price")
        setValue(product.image, forKey: "image")
        setValue(product.brand, forKey: "brand")
        setValue(product.model, forKey: "model")
        setValue(product.description, forKey: "productDescription")
        setValue(product.quantity, forKey: "quantity")
    }
}
