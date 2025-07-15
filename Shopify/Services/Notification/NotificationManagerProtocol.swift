//
//  NotificationManagerProtocol.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation

protocol NotificationManagerProtocol {
    func post(name: Notification.Name, object: Any?)
    func observe(name: Notification.Name, using: @escaping (Notification) -> Void) -> NSObjectProtocol
    func remove(observer: Any)
}