//
//  ProfileViewModel.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import Foundation

final class ProfileViewModel {
    enum State {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }
    
    // Mock user data - in a real app this would come from a user service
    private(set) var userProfile = UserProfile(
        name: "İsmail Palalı",
        email: "ismail@example.com",
        phone: "+90 555 123 4567",
        avatarURL: nil,
        memberSince: "2024",
        totalOrders: 12,
        totalSpent: 2450.75
    )
    
    var onStateChange: ((State) -> Void)?
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        state = .loading
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.state = .loaded
        }
    }
    

}

// MARK: - User Profile Model
struct UserProfile {
    let name: String
    let email: String
    let phone: String
    let avatarURL: URL?
    let memberSince: String
    let totalOrders: Int
    let totalSpent: Double
} 