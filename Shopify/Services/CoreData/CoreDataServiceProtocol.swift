//
//  CoreDataServiceProtocol.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation

protocol CoreDataServiceProtocol {
    func saveCartItem(_ product: Product)
    func removeCartItem(_ product: Product)
    func loadCartItems() -> [Product]
    func updateCartItem(_ product: Product)
}