//
//  Product.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation

struct Product: Decodable {
    let id: String
    let createdAt: String
    let name: String
    let image: String
    let price: String
    let description: String
    let model: String
    let brand: String
    var quantity: Int16?
}
