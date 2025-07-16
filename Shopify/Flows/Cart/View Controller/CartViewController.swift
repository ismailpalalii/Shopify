//
//  CartViewController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit

final class CartViewController: UIViewController {
    private let viewModel: CartViewModel

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
    
    private let tableView = UITableView()
    private let totalPriceLabel = UILabel()
    private let completeButton = UIButton(type: .system)
    private let emptyLabel = UILabel()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refresh.tintColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        return refresh
    }()

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
        navigationController?.setNavigationBarHidden(true, animated: false)

        [blueHeader, tableView, totalPriceLabel, completeButton, emptyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        blueHeader.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl

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
        NSLayoutConstraint.activate([
            blueHeader.topAnchor.constraint(equalTo: view.topAnchor),
            blueHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blueHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blueHeader.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.centerXAnchor.constraint(equalTo: blueHeader.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: blueHeader.bottomAnchor, constant: -14),

            tableView.topAnchor.constraint(equalTo: blueHeader.bottomAnchor),
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
    
    @objc private func refreshData() {
        viewModel.loadCartItems()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedProduct = viewModel.cartItems[indexPath.row]
        navigateToProductDetail(with: selectedProduct)
    }
    
    private func navigateToProductDetail(with product: Product) {
        let detailVM = viewModel.makeProductDetailViewModel(for: product)
        let detailVC = ProductDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            let product = self?.viewModel.cartItems[indexPath.row]
            if let product = product {
                self?.viewModel.removeItem(product)
            }
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
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
