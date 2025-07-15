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
    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add to Cart", for: .normal)
        btn.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
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

    private func setup() {
        [productImageView, loadingView, starImageView, priceLabel, nameLabel, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor, multiplier: 1.0),

            loadingView.centerXAnchor.constraint(equalTo: productImageView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: productImageView.centerYAnchor),

            starImageView.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 8),
            starImageView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -8),
            starImageView.widthAnchor.constraint(equalToConstant: 24),
            starImageView.heightAnchor.constraint(equalToConstant: 24),

            priceLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 12),
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),

            nameLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor),

            addButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 14),
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
        loadingView.startAnimating()
        productImageView.image = nil

        if let url = URL(string: product.image) {
            productImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.2))]) { [weak self] _ in
                self?.loadingView.stopAnimating()
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
        addToCartHandler?()
    }
    @objc private func favoriteTapped() {
        onFavoriteToggle?()
    }
}
