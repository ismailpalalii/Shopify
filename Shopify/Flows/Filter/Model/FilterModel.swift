//
//  FilterModel.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//

import Foundation

enum SortOption: String, CaseIterable {
    case oldToNew = "Old to new"
    case newToOld = "New to old"
    case priceHighToLow = "Price high to low"
    case priceLowToHigh = "Price low to high"
}

struct FilterData {
    var sortOption: SortOption = .oldToNew
    var selectedBrands: Set<String> = []
    var selectedModels: Set<String> = []
    var brandSearchText: String = ""
    var modelSearchText: String = ""
    var availableBrands: [String] = []
    var availableModels: [String] = []
}

