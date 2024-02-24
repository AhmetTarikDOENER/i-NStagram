//
//  AppDelegate.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = HomeViewController()
        window.makeKeyAndVisible()
        self.window = window
        // Add dummy notify for current user
        let id = NotificationsManager.newIdentifier()
        let model = IGNotification(
            identifier: id,
            notificationType: 1,
            profilePictureURL: "https://picsum.photos/200/300?random=14",
            username: "elonmusk",
            dateString: String.date(from: Date()) ?? "Now",
            isFollowing: nil,
            postID: "123",
            postURL: "https://picsum.photos/200/300?random=8"
        )
        NotificationsManager.shared.create(notification: model, for: "ahmettarik")
        return true
    }
}

