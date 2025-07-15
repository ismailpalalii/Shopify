//
//  ProductServiceImpl.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation
import Alamofire

final class ProductServiceImpl: ProductServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let baseURL = "https://5fc9346b2af77700165ae514.mockapi.io/products"

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func fetchProducts(
        page: Int,
        limit: Int,
        completion: @escaping (Result<[Product], Error>) -> Void
    ) {
        let parameters: Parameters = [
            "page": page,
            "limit": limit
        ]
        networkManager.request(
            url: baseURL,
            method: .get,
            parameters: parameters,
            headers: nil,
            completion: completion
        )
    }
}