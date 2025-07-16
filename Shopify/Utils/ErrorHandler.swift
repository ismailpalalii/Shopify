//
//  ErrorHandler.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit

final class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    enum ErrorType {
        case network
        case server
        case data
        case unknown
        case custom(String)
        
        var title: String {
            switch self {
            case .network:
                return "Connection Error"
            case .server:
                return "Server Error"
            case .data:
                return "Data Error"
            case .unknown:
                return "Unknown Error"
            case .custom(let title):
                return title
            }
        }
        
        var message: String {
            switch self {
            case .network:
                return "Please check your internet connection and try again."
            case .server:
                return "Something went wrong on our end. Please try again later."
            case .data:
                return "The data couldn't be loaded. Please try again."
            case .unknown:
                return "An unexpected error occurred. Please try again."
            case .custom(let message):
                return message
            }
        }
        
        var canRetry: Bool {
            switch self {
            case .network, .server:
                return true
            case .data, .unknown:
                return false
            case .custom:
                return true
            }
        }
    }
    
    func showError(
        _ error: Error,
        from viewController: UIViewController,
        retryAction: (() -> Void)? = nil
    ) {
        // Log error to Analytics and Crashlytics
        AnalyticsManager.shared.logError(error, context: "ErrorHandler")
        
        let errorType = mapErrorToType(error)
        showErrorAlert(
            type: errorType,
            from: viewController,
            retryAction: retryAction
        )
    }
    
    func showError(
        type: ErrorType,
        from viewController: UIViewController,
        retryAction: (() -> Void)? = nil
    ) {
        showErrorAlert(
            type: type,
            from: viewController,
            retryAction: retryAction
        )
    }
    
    private func showErrorAlert(
        type: ErrorType,
        from viewController: UIViewController,
        retryAction: (() -> Void)?
    ) {
        let alert = UIAlertController(
            title: type.title,
            message: type.message,
            preferredStyle: .alert
        )
        
        if type.canRetry && retryAction != nil {
            alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                retryAction?()
            })
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
    
    private func mapErrorToType(_ error: Error) -> ErrorType {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost:
                return .network
            case .timedOut, .badServerResponse:
                return .server
            default:
                return .unknown
            }
        }
        
        // Check for custom app errors
        if let appError = error as? ProductListViewModel.AppError {
            switch appError {
            case .networkUnavailable:
                return .network
            case .serverError:
                return .server
            case .invalidData:
                return .data
            case .unknown:
                return .unknown
            }
        }
        
        if let appError = error as? FavoritesViewModel.AppError {
            switch appError {
            case .networkUnavailable:
                return .network
            case .serverError:
                return .server
            case .invalidData:
                return .data
            case .unknown:
                return .unknown
            }
        }
        
        return .unknown
    }
    
    // MARK: - Toast Style Error (for less intrusive errors)
    
    func showToastError(
        _ message: String,
        from viewController: UIViewController,
        duration: TimeInterval = 3.0
    ) {
        let toastView = createToastView(message: message)
        viewController.view.addSubview(toastView)
        
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
            toastView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -20),
            toastView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toastView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Animate in
        toastView.transform = CGAffineTransform(translationX: 0, y: 100)
        UIView.animate(withDuration: 0.3) {
            toastView.transform = .identity
        }
        
        // Auto dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                toastView.transform = CGAffineTransform(translationX: 0, y: 100)
                toastView.alpha = 0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
    
    private func createToastView(message: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 0.95)
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 8
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        messageLabel.numberOfLines = 2
        
        [iconImageView, messageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            messageLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
} 