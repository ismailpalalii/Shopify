//
//  EmptyStateView.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit

final class EmptyStateView: UIView {
    enum EmptyStateType {
        case noProducts
        case noFavorites
        case noCartItems
        case noSearchResults
        case networkError
        case custom(title: String, message: String, icon: String)
        
        var title: String {
            switch self {
            case .noProducts:
                return "No Products Found"
            case .noFavorites:
                return "No Favorites Yet"
            case .noCartItems:
                return "Your Cart is Empty"
            case .noSearchResults:
                return "No Results Found"
            case .networkError:
                return "Connection Error"
            case .custom(let title, _, _):
                return title
            }
        }
        
        var message: String {
            switch self {
            case .noProducts:
                return "We couldn't find any products at the moment. Please try again later."
            case .noFavorites:
                return "Start adding products to your favorites to see them here."
            case .noCartItems:
                return "Add some products to your cart to get started with shopping."
            case .noSearchResults:
                return "Try adjusting your search terms or filters to find what you're looking for."
            case .networkError:
                return "Please check your internet connection and try again."
            case .custom(_, let message, _):
                return message
            }
        }
        
        var icon: String {
            switch self {
            case .noProducts:
                return "bag"
            case .noFavorites:
                return "star"
            case .noCartItems:
                return "cart"
            case .noSearchResults:
                return "magnifyingglass"
            case .networkError:
                return "wifi.slash"
            case .custom(_, _, let icon):
                return icon
            }
        }
    }
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textColor = .gray
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.isHidden = true
        return btn
    }()
    
    var onActionButtonTapped: (() -> Void)?
    
    init(type: EmptyStateType, showActionButton: Bool = false, actionTitle: String? = nil) {
        super.init(frame: .zero)
        setupUI()
        configure(with: type, showActionButton: showActionButton, actionTitle: actionTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        [iconImageView, titleLabel, messageLabel, actionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -60),
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func configure(with type: EmptyStateType, showActionButton: Bool, actionTitle: String?) {
        iconImageView.image = UIImage(systemName: type.icon)
        titleLabel.text = type.title
        messageLabel.text = type.message
        
        if showActionButton {
            actionButton.isHidden = false
            actionButton.setTitle(actionTitle ?? "Try Again", for: .normal)
        } else {
            actionButton.isHidden = true
        }
    }
    
    @objc private func actionButtonTapped() {
        onActionButtonTapped?()
    }
    
    func updateType(_ type: EmptyStateType) {
        iconImageView.image = UIImage(systemName: type.icon)
        titleLabel.text = type.title
        messageLabel.text = type.message
    }
} 