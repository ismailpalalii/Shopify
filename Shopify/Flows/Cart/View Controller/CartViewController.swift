//
//  CartViewController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit

final class CartViewController: UIViewController {
    private let viewModel: CartViewModel

    private let tableView = UITableView()
    private let totalPriceLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    private let emptyLabel = UILabel()

    init(viewModel: CartViewModel) {
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
        viewModel.loadCartItems()
    }

    private func setupViews() {
        title = "Cart"
        navigationController?.navigationBar.prefersLargeTitles = false

        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)

        totalPriceLabel.font = .boldSystemFont(ofSize: 22)
        totalPriceLabel.textColor = UIColor(red: 0/255, green: 82/255, blue: 204/255, alpha: 1)
        view.addSubview(totalPriceLabel)

        completeButton.setTitle("Complete", for: .normal)
        completeButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.layer.cornerRadius = 10
        completeButton.isEnabled = false
        completeButton.alpha = 0.5
        view.addSubview(completeButton)

        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)

        emptyLabel.text = "Sepetiniz boş"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        emptyLabel.font = .systemFont(ofSize: 18)
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            totalPriceLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            totalPriceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalPriceLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            completeButton.centerYAnchor.constraint(equalTo: totalPriceLabel.centerYAnchor),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completeButton.heightAnchor.constraint(equalToConstant: 44),
            completeButton.widthAnchor.constraint(equalToConstant: 150),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.onCartItemsChanged = { [weak self] items in
            self?.tableView.reloadData()
            self?.emptyLabel.isHidden = !items.isEmpty
        }
        viewModel.onTotalPriceChanged = { [weak self] total in
            self?.totalPriceLabel.text = "Total: \(String(format: "%.2f", total)) ₺"

            let hasItems = total > 0
            self?.completeButton.isEnabled = hasItems
            self?.completeButton.alpha = hasItems ? 1.0 : 0.5
        }
        viewModel.onError = { [weak self] error in
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    @objc private func completeTapped() {
        let alert = UIAlertController(title: "Complete", message: "Purchase completed successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       viewModel.cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.identifier, for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }

        let product = viewModel.cartItems[indexPath.row]
        cell.configure(with: product)

        cell.onIncrement = { [weak self] in
            self?.viewModel.increaseQuantity(for: product)
        }
        cell.onDecrement = { [weak self] in
            self?.viewModel.decreaseQuantity(for: product)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = viewModel.cartItems[indexPath.row]
            showDeleteConfirmation(for: product)
        }
    }
    
    private func showDeleteConfirmation(for product: Product) {
        let alert = UIAlertController(
            title: "Ürünü Sil",
            message: "'\(product.name)' ürününü sepetten silmek istediğinize emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.viewModel.removeItem(product)
        })
        
        present(alert, animated: true)
    }
}
