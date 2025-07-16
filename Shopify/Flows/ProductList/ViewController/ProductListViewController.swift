//
//  ProductListViewController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit

final class ProductListViewController: UIViewController {
    private let viewModel: ProductListViewModel
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
        sb.placeholder = "Search"
        sb.backgroundImage = UIImage()
        sb.searchBarStyle = .minimal
        return sb
    }()
    private let filterLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Filters:"
        lbl.font = .systemFont(ofSize: 18, weight: .medium)
        return lbl
    }()
    private let filterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Select Filter", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = UIColor(white: 0.95, alpha: 1)
        btn.layer.cornerRadius = 6
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return btn
    }()
    private let collectionView: UICollectionView
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No products found"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refresh.tintColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        return refresh
    }()

    init(viewModel: ProductListViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        viewModel.fetchFirstPage()
        setupDismissKeyboardGesture()
        updateFilterButtonTitle()
    }

    private func setupSubviews() {
        [blueHeader, searchBar, filterLabel, filterButton, collectionView, loadingView, emptyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        blueHeader.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
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

            filterLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            filterLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),

            filterButton.centerYAnchor.constraint(equalTo: filterLabel.centerYAnchor),
            filterButton.leadingAnchor.constraint(equalTo: filterLabel.trailingAnchor, constant: 16),
            filterButton.widthAnchor.constraint(equalToConstant: 130),
            filterButton.heightAnchor.constraint(equalToConstant: 38),

            collectionView.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 4),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.register(LoadingFooterCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "LoadingFooterCell")
        collectionView.refreshControl = refreshControl
    }

    private func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.reload(for: state)
            }
        }
    }

    private func reload(for state: ProductListViewModel.State) {
        // İlk sayfa yüklemede ortada büyük loading spinner
        if viewModel.isFirstPage && viewModel.isFetching {
            loadingView.startAnimating()
            loadingView.isHidden = false
        } else {
            loadingView.stopAnimating()
            loadingView.isHidden = true
        }
        switch state {
        case .idle:
            emptyLabel.isHidden = true
        case .loading:
            emptyLabel.isHidden = true
        case .loaded:
            emptyLabel.isHidden = true
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        case .empty:
            emptyLabel.isHidden = false
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        case .error(let error):
            emptyLabel.isHidden = false
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
        // Clear all filters and search when refreshing
        viewModel.clearAllFilters()
        searchBar.text = ""
        updateFilterButtonTitle()
        
        // Reset to first page and fetch fresh data
        viewModel.refreshData { [weak self] in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func showError(_ error: ProductListViewModel.AppError) {
        emptyLabel.text = error.errorDescription
        
        if error.canRetry {
            let alert = UIAlertController(
                title: "Hata",
                message: error.errorDescription,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Tekrar Dene", style: .default) { [weak self] _ in
                self?.viewModel.retryFetch()
            })
            
            alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
            
            present(alert, animated: true)
        }
    }
}



// MARK: - CollectionView DataSource & Delegate

extension ProductListViewController: UICollectionViewDelegate {
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

extension ProductListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

    // Footer Loading Spinner
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadingFooterCell", for: indexPath) as! LoadingFooterCell
            if viewModel.isFetching && !viewModel.isFirstPage && !viewModel.isLastPage {
                footer.activityIndicator.startAnimating()
                footer.isHidden = false
            } else {
                footer.activityIndicator.stopAnimating()
                footer.isHidden = true
            }
            return footer
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if viewModel.isFetching && !viewModel.isFirstPage && !viewModel.isLastPage && !viewModel.filteredProducts.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 70)
        }
        return .zero
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !viewModel.isFetching, !viewModel.isLastPage else { return }
        
        // Don't trigger pagination if filtering is active
        if viewModel.isFilteringActive {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY > contentHeight - frameHeight - 100 {
            viewModel.fetchNextPage()
        }
    }
}

// MARK: - UISearchBarDelegate
extension ProductListViewController: UISearchBarDelegate {
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
        
        // Clear all filters when clearing search
        viewModel.clearAllFilters()
        updateFilterButtonTitle()
    }
    
    private func performSearch(with searchText: String) {
        // Show loading indicator if search is not empty
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            loadingView.startAnimating()
            loadingView.isHidden = false
        }
        
        viewModel.setSearchText(searchText)
        updateFilterButtonTitle()
        
        // Hide loading indicator after a short delay
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.loadingView.stopAnimating()
                self?.loadingView.isHidden = true
            }
        }
    }
    
    @objc private func filterButtonTapped() {
        // If filtering is active, clear all filters
        if viewModel.isFilteringActive {
            viewModel.clearAllFilters()
            searchBar.text = ""
            updateFilterButtonTitle()
            return
        }
        
        // Show loading indicator
        loadingView.startAnimating()
        loadingView.isHidden = false
        
        // Fetch all products for filter first
        viewModel.fetchAllProductsForFilter { [weak self] in
            DispatchQueue.main.async {
                self?.loadingView.stopAnimating()
                self?.loadingView.isHidden = true
                
                let filterVC = FilterViewController(filterData: self?.viewModel.getCurrentFilterData() ?? FilterData())
                filterVC.delegate = self
                filterVC.modalPresentationStyle = .fullScreen
                self?.present(filterVC, animated: true)
            }
        }
    }
}

// MARK: - FilterViewControllerDelegate
extension ProductListViewController: FilterViewControllerDelegate {
    func filterViewController(_ controller: FilterViewController, didApplyFilter filterData: FilterData) {
        viewModel.applyFilter(filterData)
        updateFilterButtonTitle()
    }
    
    private func updateFilterButtonTitle() {
        if viewModel.isFilteringActive {
            filterButton.setTitle("Clear Filters", for: .normal)
            filterButton.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1) // Red color
        } else {
            filterButton.setTitle("Select Filter", for: .normal)
            filterButton.backgroundColor = UIColor(white: 0.95, alpha: 1) // Original gray
        }
    }
}

// MARK: - LoadingFooterCell
final class LoadingFooterCell: UICollectionReusableView {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicator.color = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
