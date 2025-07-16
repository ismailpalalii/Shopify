//
//  ProductCell.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//
import UIKit
import Kingfisher

final class ProductCell: UICollectionViewCell {
    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return iv
    }()
    private let loadingView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        spinner.color = .systemGray
        return spinner
    }()
    private let starImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    private let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        return lbl
    }()
    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .black
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingTail
        return lbl
    }()
    private let brandLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = .darkGray
        lbl.numberOfLines = 1
        lbl.backgroundColor = .clear
        lbl.textAlignment = .left
        return lbl
    }()
    private let modelLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = .gray
        lbl.numberOfLines = 1
        lbl.backgroundColor = .clear
        lbl.textAlignment = .left
        return lbl
    }()
    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add to Cart", for: .normal)
        btn.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        // Add visual feedback for button states
        btn.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
        btn.setBackgroundImage(UIImage(), for: .highlighted)
        btn.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        
        // Add shadow for better visual feedback
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowRadius = 4
        
        return btn
    }()

    var addToCartHandler: (() -> Void)?
    var onFavoriteToggle: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 14
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.10
        contentView.layer.shadowRadius = 7
        contentView.clipsToBounds = false
        setup()
        addFavoriteGesture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel any ongoing image loading task
        productImageView.kf.cancelDownloadTask()
        productImageView.image = nil
        loadingView.stopAnimating()
    }

    private func setup() {
        [productImageView, loadingView, starImageView, priceLabel, nameLabel, brandLabel, modelLabel, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor, multiplier: 0.8),

            loadingView.centerXAnchor.constraint(equalTo: productImageView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),

            starImageView.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 8),
            starImageView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -8),
            starImageView.widthAnchor.constraint(equalToConstant: 24),
            starImageView.heightAnchor.constraint(equalToConstant: 24),

            priceLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),

            nameLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),

            brandLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            brandLabel.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            brandLabel.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),
            brandLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),

            modelLabel.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 3),
            modelLabel.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            modelLabel.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),
            modelLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),

            addButton.topAnchor.constraint(equalTo: modelLabel.bottomAnchor, constant: 8),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }

    private func addFavoriteGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(favoriteTapped))
        starImageView.addGestureRecognizer(tap)
    }

    func configure(with product: Product, isFavorite: Bool = false) {
        nameLabel.text = product.name
        priceLabel.text = "\(product.price) ₺"
        
        // Display brand and model from product data
        brandLabel.text = product.brand.isEmpty ? "Brand: -" : "Brand: \(product.brand)"
        modelLabel.text = product.model.isEmpty ? "Model: -" : "Model: \(product.model)"
        
        loadingView.startAnimating()
        productImageView.image = nil

        if let url = URL(string: product.image) {
            // Cancel any previous image loading task
            productImageView.kf.cancelDownloadTask()
            
            productImageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .processor(DownsamplingImageProcessor(size: CGSize(width: 300, height: 240))),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheMemoryOnly
                ]
            ) { [weak self] result in
                DispatchQueue.main.async {
                    self?.loadingView.stopAnimating()
                }
            }
        } else {
            loadingView.stopAnimating()
            productImageView.image = UIImage(systemName: "photo")
        }

        if isFavorite {
            starImageView.image = UIImage(systemName: "star.fill")
            starImageView.tintColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1)
        } else {
            starImageView.image = UIImage(systemName: "star")
            starImageView.tintColor = UIColor(white: 0.82, alpha: 1)
        }
    }

    @objc private func addTapped() {
        // Add visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.addButton.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = .identity
                self.addButton.alpha = 1.0
            }
        }
        
        // Call handler
        addToCartHandler?()
    }
    @objc private func favoriteTapped() {
        // Add visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.starImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.starImageView.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.starImageView.transform = .identity
                self.starImageView.alpha = 1.0
            }
        }
        
        onFavoriteToggle?()
    }
}
