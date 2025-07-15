//
//  NotificationManagerImpl.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import Foundation

final class NotificationManagerImpl: NotificationManagerProtocol {
    func post(name: Notification.Name, object: Any?) {
        NotificationCenter.default.post(name: name, object: object)
    }

    func observe(name: Notification.Name, using: @escaping (Notification) -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: using)
    }

    func remove(observer: Any) {
        NotificationCenter.default.removeObserver(observer)
    }
}