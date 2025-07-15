//
//  CoreDataServiceProtocol.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation

protocol CoreDataServiceProtocol {
    func saveCartItem(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void)
    func removeCartItem(_ product: Product, completion: @escaping (Result<Void, Error>) -> Void)
    func loadCartItems(completion: @escaping (Result<[Product], Error>) -> Void)
    func updateCartItem(_ product: Product, quantity: String, completion: @escaping (Result<Void, Error>) -> Void)
}
