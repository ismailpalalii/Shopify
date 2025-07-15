//
//  ProductListViewController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit

final class ProductListViewController: UIViewController {
    private let viewModel: ProductListViewModel

    private let searchBar = UISearchBar()
    private let collectionView: UICollectionView
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No products found"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    init(viewModel: ProductListViewModel) {
        self.viewModel = viewModel

        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 12
        let columns: CGFloat = 4
        let itemWidth = (UIScreen.main.bounds.width - (spacing * (columns + 1))) / columns
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.4)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "E-Market"
        view.backgroundColor = .white

        setupSubviews()
        setupConstraints()
        setupCollectionView()
        setupViewModel()

        viewModel.fetchFirstPage()
    }

    private func setupSubviews() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(loadingView)
        view.addSubview(emptyLabel)
        loadingView.hidesWhenStopped = true
    }

    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 44),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.backgroundColor = .white
    }

    private func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                self?.reload(for: state)
            }
        }
    }

    private func reload(for state: ProductListViewModel.State) {
        switch state {
        case .idle:
            loadingView.stopAnimating()
            emptyLabel.isHidden = true
        case .loading:
            loadingView.startAnimating()
            emptyLabel.isHidden = true
        case .loaded:
            loadingView.stopAnimating()
            emptyLabel.isHidden = true
            collectionView.reloadData()
        case .empty:
            loadingView.stopAnimating()
            emptyLabel.isHidden = false
            collectionView.reloadData()
        case .error(let error):
            loadingView.stopAnimating()
            emptyLabel.isHidden = false
            emptyLabel.text = "Error: \(error.localizedDescription)"
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension ProductListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UICollectionViewCell()
        }
        let product = viewModel.products[indexPath.item]
        cell.configure(with: product)
        cell.addToCartHandler = { [weak self] in
            self?.viewModel.addToCart(product)
        }
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        if offsetY > contentHeight - frameHeight * 2 {
            viewModel.fetchNextPage()
        }
    }
}
