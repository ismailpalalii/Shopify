//
//  ProductServiceProtocol.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[Product], Error>) -> Void
    )
}