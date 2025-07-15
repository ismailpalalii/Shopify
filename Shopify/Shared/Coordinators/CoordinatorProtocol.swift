//
//  CoordinatorProtocol.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
