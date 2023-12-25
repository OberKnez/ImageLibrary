//
//  UIKitViewController.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 24.12.23.
//

import UIKit
import Combine
import AsyncImageSDK

class UIKitViewController: UIViewController {
    
    private var viewModel: UIKitViewModel!
    
    private var imageModels: [(AsyncImagerType, String)] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var task: AnyCancellable?
    
    static func create(with viewModel: UIKitViewModel) -> UIKitViewController {
        let view = UIKitViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        self.view.addSubview(buttonContainer)
        self.buttonContainer.addSubview(button)
        
        viewModel.fetchImages()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            
            buttonContainer.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: 70),
            buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            button.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            button.widthAnchor.constraint(equalTo: buttonContainer.widthAnchor, multiplier: 0.75),
            button.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    
        task = viewModel.asyncImages
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] images in
                self?.imageModels = images
            })
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.rowHeight = 60
        view.register(UIKitCell.self, forCellReuseIdentifier: UIKitCell.identifier)
        return view
    }()

    lazy var button: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("CLEAR CACHE", for: .normal)
        view.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var buttonContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    @objc
    private func buttonAction() {
        viewModel.clearCache()
    }
}

extension UIKitViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UIKitCell = tableView.dequeueReusableCell(withIdentifier: UIKitCell.identifier, for: indexPath) as? UIKitCell else {
            return UITableViewCell()
        }
        
        let asyncImage = imageModels[indexPath.row]
        cell.setupCell(asyncImageView: asyncImage)
        cell.layoutIfNeeded()
        
        return cell
    }
    
    
}
