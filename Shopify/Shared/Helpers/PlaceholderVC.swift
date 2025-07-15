//
//  PlaceholderVC.swift
//  Shopify
//
//  Created by İsmail Palalı on 15.07.2025.
//


import UIKit

final class PlaceholderVC: UIViewController {
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        view.backgroundColor = .systemGray6

        let label = UILabel()
        label.text = "\(title) Page"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}