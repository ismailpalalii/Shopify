//
//  AnalyticsManager.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import Foundation
import Firebase

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - Analytics Events
    
    func logProductViewed(product: Product) {
        Analytics.logEvent("product_viewed", parameters: [
            "product_id": product.id,
            "product_name": product.name,
            "product_price": product.price,
            "product_brand": product.brand
        ])
    }
    
    func logProductAddedToCart(product: Product, quantity: Int16) {
        Analytics.logEvent("product_added_to_cart", parameters: [
            "product_id": product.id,
            "product_name": product.name,
            "quantity": quantity,
            "product_price": product.price
        ])
    }
    
    func logProductRemovedFromCart(product: Product) {
        Analytics.logEvent("product_removed_from_cart", parameters: [
            "product_id": product.id,
            "product_name": product.name
        ])
    }
    
    func logProductFavorited(product: Product, isFavorite: Bool) {
        let eventName = isFavorite ? "product_favorited" : "product_unfavorited"
        Analytics.logEvent(eventName, parameters: [
            "product_id": product.id,
            "product_name": product.name
        ])
    }
    
    func logSearchPerformed(searchTerm: String, resultCount: Int) {
        Analytics.logEvent("search_performed", parameters: [
            "search_term": searchTerm,
            "result_count": resultCount
        ])
    }
    
    func logFilterApplied(filterType: String, filterValue: String) {
        Analytics.logEvent("filter_applied", parameters: [
            "filter_type": filterType,
            "filter_value": filterValue
        ])
    }
    
    func logPurchaseCompleted(totalAmount: Double, itemCount: Int) {
        Analytics.logEvent("purchase_completed", parameters: [
            "total_amount": totalAmount,
            "item_count": itemCount
        ])
    }
    
    func logScreenView(screenName: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
    }
    
    // MARK: - User Properties
    
    func setUserProperty(key: String, value: String) {
        Analytics.setUserProperty(value, forName: key)
    }
    
    func setUserID(userID: String) {
        Analytics.setUserID(userID)
    }
    
    // MARK: - Crash Reporting
    
    func logError(_ error: Error, context: String? = nil) {
        var customKeysAndValues: [String: Any] = [:]
        
        if let context = context {
            customKeysAndValues["context"] = context
        }
        
        customKeysAndValues["error_description"] = error.localizedDescription
        customKeysAndValues["error_domain"] = (error as NSError).domain
        customKeysAndValues["error_code"] = (error as NSError).code
        
        Crashlytics.crashlytics().setCustomKeysAndValues(customKeysAndValues)
        Crashlytics.crashlytics().record(error: error)
    }
    
    func logNonFatalError(_ error: Error, context: String? = nil) {
        var customKeysAndValues: [String: Any] = [:]
        
        if let context = context {
            customKeysAndValues["context"] = context
        }
        
        customKeysAndValues["error_description"] = error.localizedDescription
        customKeysAndValues["error_domain"] = (error as NSError).domain
        customKeysAndValues["error_code"] = (error as NSError).code
        
        Crashlytics.crashlytics().setCustomKeysAndValues(customKeysAndValues)
        Crashlytics.crashlytics().record(error: error)
    }
    
    func logMessage(_ message: String, level: String = "info") {
        Crashlytics.crashlytics().log("\(level.uppercased()): \(message)")
    }
    
    func setUserIdentifier(_ userID: String) {
        Crashlytics.crashlytics().setUserID(userID)
    }
    
    func setCustomValue(_ value: Any, forKey key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
} 
