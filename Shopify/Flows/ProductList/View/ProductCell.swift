//
//  ProductCell.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit

final class ProductCell: UICollectionViewCell {
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let addButton = UIButton(type: .system)

    var addToCartHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(white: 0.97, alpha: 1)
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        [nameLabel, priceLabel, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        addButton.setTitle("Add to Cart", for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 6
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            addButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func configure(with product: Product) {
        nameLabel.text = product.name
        priceLabel.text = "\(product.price) ₺"
    }

    @objc private func addTapped() {
        addToCartHandler?()
    }
}
