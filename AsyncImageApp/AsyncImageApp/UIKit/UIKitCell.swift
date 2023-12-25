//
//  UIKitCell.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 24.12.23.
//

import UIKit
import Combine
import AsyncImageSDK

class UIKitCell: UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    lazy var asyncImageViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var cancellables = Set<AnyCancellable>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    func setupLayout() {
        self.contentView.addSubview(asyncImageViewContainer)
        self.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            asyncImageViewContainer.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            asyncImageViewContainer.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            asyncImageViewContainer.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            asyncImageViewContainer.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.75),
            
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: asyncImageViewContainer.trailingAnchor)
        ])
    }
    
    
    func setupCell(asyncImageView: (AsyncImagerType, String)) {
        guard let imageView = asyncImageView.0.imageView else { return }
        asyncImageViewContainer.subviews.forEach { $0.removeFromSuperview() }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        asyncImageViewContainer.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: asyncImageViewContainer.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: asyncImageViewContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: asyncImageViewContainer.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: asyncImageViewContainer.leadingAnchor)
        ])
        label.text = asyncImageView.1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
