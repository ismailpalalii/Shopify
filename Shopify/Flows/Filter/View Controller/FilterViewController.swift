//
//  FilterViewController.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ controller: FilterViewController, didApplyFilter filterData: FilterData)
}

final class FilterViewController: UIViewController {
    weak var delegate: FilterViewControllerDelegate?
    private var filterData: FilterData
    
    // Header
    private let headerView = UIView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let headerSeparator = UIView()
    
    // Main Scroll View
    private let mainScrollView = UIScrollView()
    private let contentView = UIView()
    
    // Sort By Section
    private let sortByLabel = UILabel()
    private let sortByStackView = UIStackView()
    private var sortRadioButtons: [UIButton] = []
    
    // Brand Section
    private let brandSeparator = UIView()
    private let brandLabel = UILabel()
    private let brandSearchBar = UISearchBar()
    private let brandScrollView = UIScrollView()
    private let brandStackView = UIStackView()
    private var brandCheckboxes: [UIButton] = []
    private var filteredBrands: [String] = []
    
    // Model Section
    private let modelSeparator = UIView()
    private let modelLabel = UILabel()
    private let modelSearchBar = UISearchBar()
    private let modelScrollView = UIScrollView()
    private let modelStackView = UIStackView()
    private var modelCheckboxes: [UIButton] = []
    private var filteredModels: [String] = []
    
    // Primary Button
    private let primaryButton = UIButton(type: .system)
    
    init(filterData: FilterData) {
        self.filterData = filterData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupBindings()
        populateData()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Header
        headerView.backgroundColor = .systemBackground
        view.addSubview(headerView)
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        headerView.addSubview(closeButton)
        
        titleLabel.text = "Filter"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        
        clearButton.setTitle("Clear", for: .normal)
        clearButton.setTitleColor(.systemBlue, for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        headerView.addSubview(clearButton)
        
        headerSeparator.backgroundColor = .separator
        headerView.addSubview(headerSeparator)
        
        // Main Scroll View
        mainScrollView.showsVerticalScrollIndicator = true
        mainScrollView.backgroundColor = .systemBackground
        view.addSubview(mainScrollView)
        mainScrollView.addSubview(contentView)
        
        // Sort By Section
        sortByLabel.text = "Sort By"
        sortByLabel.font = .systemFont(ofSize: 16, weight: .medium)
        sortByLabel.textColor = .label
        contentView.addSubview(sortByLabel)
        
        sortByStackView.axis = .vertical
        sortByStackView.spacing = 16
        sortByStackView.alignment = .leading
        contentView.addSubview(sortByStackView)
        
        // Brand Section
        brandSeparator.backgroundColor = .separator
        contentView.addSubview(brandSeparator)
        
        brandLabel.text = "Brand"
        brandLabel.font = .systemFont(ofSize: 16, weight: .medium)
        brandLabel.textColor = .label
        contentView.addSubview(brandLabel)
        
        brandSearchBar.placeholder = "Search"
        brandSearchBar.searchBarStyle = .minimal
        brandSearchBar.delegate = self
        brandSearchBar.backgroundColor = .systemGray6
        contentView.addSubview(brandSearchBar)
        
        brandScrollView.showsVerticalScrollIndicator = true
        brandScrollView.backgroundColor = .systemBackground
        brandScrollView.alwaysBounceVertical = true
        brandScrollView.contentInsetAdjustmentBehavior = .never
        brandScrollView.layer.borderColor = UIColor.separator.cgColor
        brandScrollView.layer.borderWidth = 0.5
        brandScrollView.layer.cornerRadius = 8
        contentView.addSubview(brandScrollView)
        
        brandStackView.axis = .vertical
        brandStackView.spacing = 12
        brandStackView.alignment = .leading
        brandScrollView.addSubview(brandStackView)
        
        // Model Section
        modelSeparator.backgroundColor = .separator
        contentView.addSubview(modelSeparator)
        
        modelLabel.text = "Model"
        modelLabel.font = .systemFont(ofSize: 16, weight: .medium)
        modelLabel.textColor = .label
        contentView.addSubview(modelLabel)
        
        modelSearchBar.placeholder = "Search"
        modelSearchBar.searchBarStyle = .minimal
        modelSearchBar.delegate = self
        modelSearchBar.backgroundColor = .systemGray6
        contentView.addSubview(modelSearchBar)
        
        modelScrollView.showsVerticalScrollIndicator = true
        modelScrollView.backgroundColor = .systemBackground
        modelScrollView.alwaysBounceVertical = true
        modelScrollView.contentInsetAdjustmentBehavior = .never
        modelScrollView.layer.borderColor = UIColor.separator.cgColor
        modelScrollView.layer.borderWidth = 0.5
        modelScrollView.layer.cornerRadius = 8
        contentView.addSubview(modelScrollView)
        
        modelStackView.axis = .vertical
        modelStackView.spacing = 12
        modelStackView.alignment = .leading
        modelScrollView.addSubview(modelStackView)
        
        // Primary Button
        primaryButton.setTitle("Filter", for: .normal)
        primaryButton.backgroundColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.layer.cornerRadius = 12
        primaryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        view.addSubview(primaryButton)
    }
    
    private func setupConstraints() {
        [headerView, mainScrollView, contentView, sortByLabel, sortByStackView, brandSeparator, brandLabel, brandSearchBar, brandScrollView, brandStackView, modelSeparator, modelLabel, modelSearchBar, modelScrollView, modelStackView, primaryButton, closeButton, titleLabel, clearButton, headerSeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            closeButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            clearButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            clearButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 50),
            clearButton.heightAnchor.constraint(equalToConstant: 30),
            
            headerSeparator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerSeparator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerSeparator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            headerSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Main Scroll View
            mainScrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -16),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
            
            // Sort By Section
            sortByLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            sortByLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sortByLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            sortByStackView.topAnchor.constraint(equalTo: sortByLabel.bottomAnchor, constant: 16),
            sortByStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sortByStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Brand Section
            brandSeparator.topAnchor.constraint(equalTo: sortByStackView.bottomAnchor, constant: 24),
            brandSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            brandSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            brandSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            brandLabel.topAnchor.constraint(equalTo: brandSeparator.bottomAnchor, constant: 24),
            brandLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            brandLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            brandSearchBar.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 16),
            brandSearchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            brandSearchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            brandSearchBar.heightAnchor.constraint(equalToConstant: 36),
            
            // Brand Scroll View - Fixed Height
            brandScrollView.topAnchor.constraint(equalTo: brandSearchBar.bottomAnchor, constant: 16),
            brandScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            brandScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            brandScrollView.heightAnchor.constraint(equalToConstant: 200),
            
            // Brand Stack View inside Brand Scroll View
            brandStackView.topAnchor.constraint(equalTo: brandScrollView.topAnchor, constant: 8),
            brandStackView.leadingAnchor.constraint(equalTo: brandScrollView.leadingAnchor, constant: 8),
            brandStackView.trailingAnchor.constraint(equalTo: brandScrollView.trailingAnchor, constant: -8),
            brandStackView.bottomAnchor.constraint(equalTo: brandScrollView.bottomAnchor, constant: -8),
            brandStackView.widthAnchor.constraint(equalTo: brandScrollView.widthAnchor, constant: -16),
            
            // Model Section
            modelSeparator.topAnchor.constraint(equalTo: brandScrollView.bottomAnchor, constant: 24),
            modelSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            modelSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            modelSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            
            modelLabel.topAnchor.constraint(equalTo: modelSeparator.bottomAnchor, constant: 24),
            modelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            modelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            modelSearchBar.topAnchor.constraint(equalTo: modelLabel.bottomAnchor, constant: 16),
            modelSearchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            modelSearchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            modelSearchBar.heightAnchor.constraint(equalToConstant: 36),
            
            // Model Scroll View - Fixed Height
            modelScrollView.topAnchor.constraint(equalTo: modelSearchBar.bottomAnchor, constant: 16),
            modelScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            modelScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            modelScrollView.heightAnchor.constraint(equalToConstant: 200),
            
            // Model Stack View inside Model Scroll View
            modelStackView.topAnchor.constraint(equalTo: modelScrollView.topAnchor, constant: 8),
            modelStackView.leadingAnchor.constraint(equalTo: modelScrollView.leadingAnchor, constant: 8),
            modelStackView.trailingAnchor.constraint(equalTo: modelScrollView.trailingAnchor, constant: -8),
            modelStackView.bottomAnchor.constraint(equalTo: modelScrollView.bottomAnchor, constant: -8),
            modelStackView.widthAnchor.constraint(equalTo: modelScrollView.widthAnchor, constant: -16),
            
            // Content View bottom constraint
            modelScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // Primary Button
            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            primaryButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBindings() {
        brandSearchBar.text = filterData.brandSearchText
        modelSearchBar.text = filterData.modelSearchText
    }
    
    private func populateData() {
        setupSortOptions()
        setupBrandOptions()
        setupModelOptions()
    }
    
    private func setupSortOptions() {
        sortRadioButtons.removeAll()
        sortByStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for sortOption in SortOption.allCases {
            let button = createRadioButton(title: sortOption.rawValue, isSelected: filterData.sortOption == sortOption)
            button.tag = SortOption.allCases.firstIndex(of: sortOption) ?? 0
            button.addTarget(self, action: #selector(sortOptionTapped(_:)), for: .touchUpInside)
            sortRadioButtons.append(button)
            sortByStackView.addArrangedSubview(button)
        }
    }
    
    private func setupBrandOptions() {
        brandCheckboxes.removeAll()
        brandStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        filteredBrands = filterData.availableBrands.filter { brand in
            filterData.brandSearchText.isEmpty || brand.lowercased().contains(filterData.brandSearchText.lowercased())
        }
        
        for brand in filteredBrands {
            let button = createCheckboxButton(title: brand, isSelected: filterData.selectedBrands.contains(brand))
            button.addTarget(self, action: #selector(brandTapped(_:)), for: .touchUpInside)
            brandCheckboxes.append(button)
            brandStackView.addArrangedSubview(button)
        }
        
        // Update scroll view content size
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.brandScrollView.layoutIfNeeded()
            self.brandStackView.layoutIfNeeded()
            
            let contentHeight = self.brandStackView.systemLayoutSizeFitting(
                CGSize(width: self.brandScrollView.frame.width - 16, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height
            
            self.brandScrollView.contentSize = CGSize(width: self.brandScrollView.frame.width, height: max(contentHeight + 16, 50))
        }
    }
    
    private func setupModelOptions() {
        modelCheckboxes.removeAll()
        modelStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        filteredModels = filterData.availableModels.filter { model in
            filterData.modelSearchText.isEmpty || model.lowercased().contains(filterData.modelSearchText.lowercased())
        }
        
        for model in filteredModels {
            let button = createCheckboxButton(title: model, isSelected: filterData.selectedModels.contains(model))
            button.addTarget(self, action: #selector(modelTapped(_:)), for: .touchUpInside)
            modelCheckboxes.append(button)
            modelStackView.addArrangedSubview(button)
        }
        
        // Update scroll view content size
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.modelScrollView.layoutIfNeeded()
            self.modelStackView.layoutIfNeeded()
            
            let contentHeight = self.modelStackView.systemLayoutSizeFitting(
                CGSize(width: self.modelScrollView.frame.width - 16, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height
            
            self.modelScrollView.contentSize = CGSize(width: self.modelScrollView.frame.width, height: max(contentHeight + 16, 50))
        }
    }
    
    private func createRadioButton(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        let circleImage = UIImage(systemName: isSelected ? "largecircle.fill.circle" : "circle")
        button.setImage(circleImage, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.tintColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.7
        button.contentHorizontalAlignment = .leading
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    private func createCheckboxButton(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton(type: .system)
        let checkImage = UIImage(systemName: isSelected ? "checkmark.square.fill" : "square")
        button.setImage(checkImage, for: .normal)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.tintColor = UIColor(red: 37/255, green: 99/255, blue: 235/255, alpha: 1)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.6
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.contentHorizontalAlignment = .leading
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }
    
    @objc private func sortOptionTapped(_ sender: UIButton) {
        let selectedOption = SortOption.allCases[sender.tag]
        filterData.sortOption = selectedOption
        setupSortOptions()
    }
    
    @objc private func brandTapped(_ sender: UIButton) {
        let brandIndex = brandCheckboxes.firstIndex(of: sender) ?? 0
        let brandName = filteredBrands[brandIndex]
        
        if filterData.selectedBrands.contains(brandName) {
            filterData.selectedBrands.remove(brandName)
        } else {
            filterData.selectedBrands.insert(brandName)
        }
        setupBrandOptions()
    }
    
    @objc private func modelTapped(_ sender: UIButton) {
        let modelIndex = modelCheckboxes.firstIndex(of: sender) ?? 0
        let modelName = filteredModels[modelIndex]
        
        if filterData.selectedModels.contains(modelName) {
            filterData.selectedModels.remove(modelName)
        } else {
            filterData.selectedModels.insert(modelName)
        }
        setupModelOptions()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func clearTapped() {
        // Clear all filters
        filterData.sortOption = .oldToNew
        filterData.selectedBrands.removeAll()
        filterData.selectedModels.removeAll()
        filterData.brandSearchText = ""
        filterData.modelSearchText = ""
        
        // Reset search bars
        brandSearchBar.text = ""
        modelSearchBar.text = ""
        
        // Refresh UI
        populateData()
        
        // Apply cleared filters
        delegate?.filterViewController(self, didApplyFilter: filterData)
    }
    
    @objc private func primaryTapped() {
        delegate?.filterViewController(self, didApplyFilter: filterData)
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension FilterViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar == brandSearchBar {
            filterData.brandSearchText = searchText
            setupBrandOptions()
        } else if searchBar == modelSearchBar {
            filterData.modelSearchText = searchText
            setupModelOptions()
        }
    }
}
