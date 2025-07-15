//
//  ProductDetailViewController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit
import Kingfisher

final class ProductDetailViewController: UIViewController {
    private let viewModel: ProductDetailViewModel
    
    // Custom navbar
    private let customNavBar = UIView()
    private let backButton = UIButton(type: .system)
    private let navTitleLabel = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    
    private let favoriteImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        iv.tintColor = UIColor(white: 0.82, alpha: 1)
        return iv
    }()
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let priceTitleLabel = UILabel()
    private let priceLabel = UILabel()
    
    private let priceStackView = UIStackView()
    private let bottomStackView = UIStackView()
    
    private let addToCartButton = UIButton(type: .system)
    
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        setupConstraints()
        setupBindings()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide default nav bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore navigation bar for other screens
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupViews() {
        // Custom Nav Bar setup
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        view.addSubview(customNavBar)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .white
        backButton.setTitle(nil, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        
        navTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        navTitleLabel.text = viewModel.product.name
        navTitleLabel.textColor = .white
        navTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        navTitleLabel.textAlignment = .center
        navTitleLabel.numberOfLines = 1
        navTitleLabel.lineBreakMode = .byTruncatingTail
        customNavBar.addSubview(navTitleLabel)
        
        // ScrollView and content setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        priceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(favoriteImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(bottomStackView)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(favoriteTapped))
        favoriteImageView.addGestureRecognizer(tap)
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .black
        
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .black
        
        priceTitleLabel.font = .systemFont(ofSize: 16)
        priceTitleLabel.textColor = UIColor(red: 0/255, green: 82/255, blue: 204/255, alpha: 1)
        priceTitleLabel.text = "Price:"
        
        priceLabel.font = .boldSystemFont(ofSize: 20)
        priceLabel.textColor = .black
        
        priceStackView.axis = .vertical
        priceStackView.alignment = .leading
        priceStackView.spacing = 4
        priceStackView.addArrangedSubview(priceTitleLabel)
        priceStackView.addArrangedSubview(priceLabel)
        
        addToCartButton.setTitle("Add to Cart", for: .normal)
        addToCartButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        addToCartButton.setTitleColor(.white, for: .normal)
        addToCartButton.layer.cornerRadius = 10
        addToCartButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .center
        bottomStackView.spacing = 16
        bottomStackView.addArrangedSubview(priceStackView)
        bottomStackView.addArrangedSubview(addToCartButton)
        
        addToCartButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Custom Nav Bar Constraints
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 90),
            
            // Back button aynı hizada ve biraz aşağıda
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: navTitleLabel.centerYAnchor),
            backButton.topAnchor.constraint(equalTo: customNavBar.topAnchor, constant: 56),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Title ortalanmış ve aynı hizada
            navTitleLabel.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            navTitleLabel.topAnchor.constraint(equalTo: customNavBar.topAnchor, constant: 56),
            navTitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            navTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: customNavBar.trailingAnchor, constant: -40),
            
            // ScrollView navbar altından başlasın
            scrollView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView inside scrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            // ImageView
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.6),
            
            // Favorite ImageView on image top-right (fixed size)
            favoriteImageView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 12),
            favoriteImageView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -12),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 24),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title label below image
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Description label below title
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Bottom stack view with price and Add to Cart button
            bottomStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            // Add to Cart button height fixed
            addToCartButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupBindings() {
        viewModel.onFavoriteStatusChange = { [weak self] isFav in
            DispatchQueue.main.async {
                self?.updateFavoriteButton(isFavorite: isFav)
            }
        }
        viewModel.onCartAdded = { [weak self] in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: "Product added to cart.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    private func updateUI() {
        titleLabel.text = viewModel.product.name
        descriptionLabel.text = viewModel.product.description
        priceLabel.text = "\(viewModel.product.price) ₺"
        
        if let url = URL(string: viewModel.product.image) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        
        updateFavoriteButton(isFavorite: viewModel.isFavorite)
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        if isFavorite {
            favoriteImageView.image = UIImage(systemName: "star.fill")
            favoriteImageView.tintColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1)
        } else {
            favoriteImageView.image = UIImage(systemName: "star")
            favoriteImageView.tintColor = UIColor(white: 0.82, alpha: 1)
        }
    }
    
    @objc private func favoriteTapped() {
        viewModel.toggleFavorite()
    }
    
    @objc private func addToCartTapped() {
        viewModel.addToCart(viewModel.product)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
