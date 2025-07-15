//
//  NetworkManagerProtocol.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation
import Alamofire

protocol NetworkManagerProtocol {
    func request<T: Decodable>(
        url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters?,
        headers: HTTPHeaders?,
        completion: @escaping (Result<T, Error>) -> Void
    )
}
