//
//  CartItemCell.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit

final class CartItemCell: UITableViewCell {
    static let identifier = "CartItemCell"

    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    
    private let decrementButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let incrementButton = UIButton(type: .system)
    
    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textColor = .black
        
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = UIColor(red: 0/255, green: 82/255, blue: 204/255, alpha: 1)
        
        decrementButton.setTitle("-", for: .normal)
        decrementButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        decrementButton.setTitleColor(.white, for: .normal)
        decrementButton.backgroundColor = UIColor(white: 0.9, alpha: 1)
        decrementButton.layer.cornerRadius = 6
        decrementButton.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)

        incrementButton.setTitle("+", for: .normal)
        incrementButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        incrementButton.setTitleColor(.white, for: .normal)
        incrementButton.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        incrementButton.layer.cornerRadius = 6
        incrementButton.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)

        quantityLabel.font = .boldSystemFont(ofSize: 18)
        quantityLabel.textColor = .white
        quantityLabel.textAlignment = .center
        quantityLabel.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        quantityLabel.layer.cornerRadius = 6
        quantityLabel.layer.masksToBounds = true
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(decrementButton)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(incrementButton)
    }

    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        decrementButton.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        incrementButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: decrementButton.leadingAnchor, constant: -12),

            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            incrementButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            incrementButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            incrementButton.widthAnchor.constraint(equalToConstant: 32),
            incrementButton.heightAnchor.constraint(equalToConstant: 32),

            quantityLabel.trailingAnchor.constraint(equalTo: incrementButton.leadingAnchor, constant: -8),
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 40),
            quantityLabel.heightAnchor.constraint(equalToConstant: 32),

            decrementButton.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -8),
            decrementButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            decrementButton.widthAnchor.constraint(equalToConstant: 32),
            decrementButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func configure(with product: Product) {
        nameLabel.text = product.name
        priceLabel.text = "\(product.price) ₺"
        quantityLabel.text = "\(product.quantity ?? 1)"
    }

    @objc private func incrementTapped() {
        onIncrement?()
    }

    @objc private func decrementTapped() {
        onDecrement?()
    }
}