//
//  AppViewController.swift
//  AsyncImages
//
//  Created by Vuk Knezevic on 24.12.23.
//

import UIKit
import SwiftUI
import AsyncImageSDK

class AppViewController: UITabBarController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .yellow
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViewControllers()
    }
    
    let firstVC = UINavigationController(rootViewController: UIKitViewController.create(with: DefaultUIKitViewModel()))
    let secondVC = UINavigationController(rootViewController: UIHostingController(rootView: SwiftUIController()))

    func setupViewControllers() {
        
        firstVC.tabBarItem.image = UIImage(systemName: "airtag")
        firstVC.tabBarItem.selectedImage = UIImage(systemName: "airtag.fill")
        firstVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        firstVC.tabBarItem.title = "UIKit"
        firstVC.tabBarItem.tag = 1

        secondVC.tabBarItem.image = UIImage(systemName: "macpro.gen1")
        secondVC.tabBarItem.selectedImage = UIImage(systemName: "macpro.gen1.fill")
        secondVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        secondVC.tabBarItem.title = "SwiftUI"
        secondVC.tabBarItem.tag = 2

        viewControllers = [firstVC, secondVC]
        
    }
}


extension AppViewController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if selectedViewController != firstVC {
            selectedIndex = item.tag
            AsyncImageManager.changeInterface(.UIKit)
        }
        if selectedViewController != secondVC {
            selectedIndex = item.tag
            AsyncImageManager.changeInterface(.SwiftUI)
        }
    }
}
