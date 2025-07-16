//
//  ProfileViewController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    private let viewModel: ProfileViewModel
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    private let blueHeader: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        return v
    }()
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "E-Market"
        lbl.font = UIFont.boldSystemFont(ofSize: 22)
        lbl.textColor = .white
        return lbl
    }()
    
    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        v.layer.cornerRadius = 20
        return v
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "person.fill")
        iv.tintColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 24)
        lbl.textColor = .white
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let emailLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textColor = .white.withAlphaComponent(0.8)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let memberSinceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .white.withAlphaComponent(0.7)
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 20
        sv.backgroundColor = .white
        sv.layer.cornerRadius = 15
        sv.layer.shadowColor = UIColor.black.cgColor
        sv.layer.shadowOffset = CGSize(width: 0, height: 2)
        sv.layer.shadowOpacity = 0.1
        sv.layer.shadowRadius = 8
        return sv
    }()
    
    private let ordersStatView = StatView(title: "Orders", value: "0", icon: "bag")
    private let spentStatView = StatView(title: "Total Spent", value: "₺0", icon: "creditcard")
    

    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 250/255, alpha: 1)
        
        setupSubviews()
        setupConstraints()
        updateUI()
    }
    
    private func setupSubviews() {
        [blueHeader, scrollView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        blueHeader.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        [contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        [headerView, statsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        [avatarImageView, nameLabel, emailLabel, memberSinceLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }
        
        [ordersStatView, spentStatView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            statsStackView.addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blueHeader.topAnchor.constraint(equalTo: view.topAnchor),
            blueHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blueHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blueHeader.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.centerXAnchor.constraint(equalTo: blueHeader.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: blueHeader.bottomAnchor, constant: -14),

            scrollView.topAnchor.constraint(equalTo: blueHeader.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 200),
            
            avatarImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            emailLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            memberSinceLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            memberSinceLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            memberSinceLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            statsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsStackView.heightAnchor.constraint(equalToConstant: 100),
            statsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    

    
    private func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleStateChange(state)
            }
        }
    }
    
    private func handleStateChange(_ state: ProfileViewModel.State) {
        switch state {
        case .loading:
            // Show loading if needed
            break
        case .loaded:
            updateUI()
        case .error(let message):
            showError(message)
        case .idle:
            break
        }
    }
    
    private func updateUI() {
        let profile = viewModel.userProfile
        
        nameLabel.text = profile.name
        emailLabel.text = profile.email
        memberSinceLabel.text = "Member since \(profile.memberSince)"
        
        ordersStatView.updateValue("\(profile.totalOrders)")
        spentStatView.updateValue("₺\(String(format: "%.2f", profile.totalSpent))")
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}





class StatView: UIView {
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        return iv
    }()
    
    private let valueLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.textColor = .black
        lbl.textAlignment = .center
        return lbl
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textColor = .gray
        lbl.textAlignment = .center
        return lbl
    }()
    
    init(title: String, value: String, icon: String) {
        super.init(frame: .zero)
        setupUI(title: title, value: value, icon: icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, value: String, icon: String) {
        [iconImageView, valueLabel, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            valueLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        titleLabel.text = title
        valueLabel.text = value
        iconImageView.image = UIImage(systemName: icon)
    }
    
    func updateValue(_ newValue: String) {
        valueLabel.text = newValue
    }
}

 