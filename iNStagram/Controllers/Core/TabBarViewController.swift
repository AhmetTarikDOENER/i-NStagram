//
//  TabBarViewController.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = HomeViewController()
        let explore = ExploreViewController()
        let camera = CameraViewController()
        let notifications = NotificationsViewController()
        let profile = ProfileViewController()
        
        let navVC1 = UINavigationController(rootViewController: home)
        let navVC2 = UINavigationController(rootViewController: explore)
        let navVC3 = UINavigationController(rootViewController: camera)
        let navVC4 = UINavigationController(rootViewController: notifications)
        let navVC5 = UINavigationController(rootViewController: profile)
        
        navVC1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        navVC2.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "safari"), tag: 2)
        navVC3.tabBarItem = UITabBarItem(title: "Camera", image: UIImage(systemName: "camera"), tag: 3)
        navVC4.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(systemName: "bell"), tag: 4)
        navVC5.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 5)
        
        setViewControllers([navVC1, navVC2, navVC3, navVC4, navVC5], animated: false)
    }
}
