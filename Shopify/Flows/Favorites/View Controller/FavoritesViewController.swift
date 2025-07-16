//
//  FavoritesViewController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit

final class FavoritesViewController: UIViewController {
    private let viewModel: FavoritesViewModel
    private var searchDebounceTimer: Timer?
    private let searchDebounceInterval: TimeInterval = 0.5

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
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search favorites"
        sb.backgroundImage = UIImage()
        sb.searchBarStyle = .minimal
        return sb
    }()
    private let collectionView: UICollectionView
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyStateView = EmptyStateView(type: .noFavorites)
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refresh.tintColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        return refresh
    }()

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 12
        let columns: CGFloat = 2
        let totalSpacing = spacing * (columns + 1)
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / columns
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.6)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        searchDebounceTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupSubviews()
        setupConstraints()
        setupCollectionView()
        setupViewModel()
        searchBar.delegate = self
        viewModel.loadFavorites()
        setupDismissKeyboardGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        // Refresh favorites when view appears
        viewModel.loadFavorites()
    }

    private func setupSubviews() {
        [blueHeader, searchBar, collectionView, loadingView, emptyStateView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        blueHeader.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        emptyStateView.isHidden = true
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blueHeader.topAnchor.constraint(equalTo: view.topAnchor),
            blueHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blueHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blueHeader.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.centerXAnchor.constraint(equalTo: blueHeader.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: blueHeader.bottomAnchor, constant: -14),

            searchBar.topAnchor.constraint(equalTo: blueHeader.bottomAnchor, constant: 6),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.refreshControl = refreshControl
    }

    private func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.reload(for: state)
            }
        }
        
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                ErrorHandler.shared.showToastError(
                    "Failed to add item to cart. Please try again.",
                    from: self ?? UIViewController()
                )
            }
        }
    }

    private func reload(for state: FavoritesViewModel.State) {
        if viewModel.favoriteProducts.isEmpty && viewModel.state == .loading {
            loadingView.startAnimating()
            loadingView.isHidden = false
        } else {
            loadingView.stopAnimating()
            loadingView.isHidden = true
        }
        
        switch state {
        case .idle:
            emptyStateView.isHidden = true
        case .loading:
            emptyStateView.isHidden = true
        case .loaded:
            emptyStateView.isHidden = true
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        case .empty:
            // Check if we're searching to show appropriate empty state
            if !viewModel.currentSearchText.isEmpty {
                emptyStateView.updateType(.noSearchResults)
            } else {
                emptyStateView.updateType(.noFavorites)
            }
            emptyStateView.isHidden = false
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        case .error(let error):
            emptyStateView.updateType(.custom(title: "Error", message: error.errorDescription ?? "", icon: "exclamationmark.triangle"))
            emptyStateView.isHidden = false
            showError(error)
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    @objc private func refreshData() {
        viewModel.loadFavorites()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func showError(_ error: FavoritesViewModel.AppError) {
        emptyStateView.updateType(.custom(title: "Error", message: error.errorDescription ?? "", icon: "exclamationmark.triangle"))
        
        if error.canRetry {
            let alert = UIAlertController(
                title: "Error",
                message: error.errorDescription,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                self?.viewModel.retryFetch()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
    }
}

// MARK: - CollectionView DataSource & Delegate

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = viewModel.filteredProducts[indexPath.item]
        navigateToProductDetail(with: selectedProduct)
    }

    private func navigateToProductDetail(with product: Product) {
        let detailVM = viewModel.makeProductDetailViewModel(for: product)
        let detailVC = ProductDetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.filteredProducts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }
        let product = viewModel.filteredProducts[indexPath.item]
        cell.configure(with: product, isFavorite: viewModel.isFavorite(product))
        cell.addToCartHandler = { [weak self] in
            self?.viewModel.addToCart(product)
        }
        cell.onFavoriteToggle = { [weak self] in
            guard let self = self else { return }
            self.viewModel.toggleFavorite(product) {
                if let visibleIndex = self.viewModel.filteredProducts.firstIndex(where: { $0.id == product.id }) {
                    let indexPath = IndexPath(item: visibleIndex, section: 0)
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension FavoritesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cancel previous timer
        searchDebounceTimer?.invalidate()
        
        // Start new timer with debounce interval
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: searchDebounceInterval, repeats: false) { [weak self] _ in
            self?.performSearch(with: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchDebounceTimer?.invalidate()
        performSearch(with: searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchDebounceTimer?.invalidate()
        performSearch(with: "")
    }
    
    private func performSearch(with searchText: String) {
        viewModel.setSearchText(searchText)
    }
} 
