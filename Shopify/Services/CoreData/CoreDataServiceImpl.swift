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

    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
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
                    cartItem.setValue(product.id, forKey: "id")
                    cartItem.setValue(product.name, forKey: "name")
                    cartItem.setValue(product.price, forKey: "price")
                    cartItem.setValue(product.image, forKey: "image")
                    cartItem.setValue(quantity, forKey: "quantity")
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
            context.perform {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CartItem")
                do {
                    let items = try self.context.fetch(fetchRequest)
                    let products = items.compactMap { obj -> Product? in
                        guard
                            let id = obj.value(forKey: "id") as? String,
                            let name = obj.value(forKey: "name") as? String,
                            let price = obj.value(forKey: "price") as? String,
                            let image = obj.value(forKey: "image") as? String,
                            let quantity = obj.value(forKey: "quantity") as? Int16
                        else { return nil }
                        return Product(
                            id: id,
                            createdAt: "",
                            name: name,
                            image: image,
                            price: price,
                            description: "",
                            model: "",
                            brand: "",
                            quantity: quantity
                        )
                    }
                    completion(.success(products))
                } catch {
                    completion(.failure(CoreDataServiceError.fetchFailed(error)))
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
                        // ürün yok, normal durum
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
        context.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteProduct")
            do {
                let items = try self.context.fetch(fetchRequest)
                let ids = items.compactMap { $0.value(forKey: "id") as? String }
                completion(.success(ids))
            } catch {
                completion(.failure(CoreDataServiceError.fetchFailed(error)))
            }
        }
    }
}
