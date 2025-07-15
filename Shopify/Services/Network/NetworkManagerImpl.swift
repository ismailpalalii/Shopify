//
//  NetworkManagerImpl.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation
import Alamofire

final class NetworkManagerImpl: NetworkManagerProtocol {
    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func request<T: Decodable>(
        url: URLConvertible,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        session.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let decoded):
                    completion(.success(decoded))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}