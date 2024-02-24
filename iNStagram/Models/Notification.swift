//
//  Notification.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import Foundation

struct IGNotification: Codable {
    let notificationType: Int
    let profilePictureURL: String
    let username: String
    let isFollowing: Bool?
    let postID: String?
    let postURL: String?
}
