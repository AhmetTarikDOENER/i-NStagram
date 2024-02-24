//
//  NotificationCellViewModels.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 24.02.2024.
//

import Foundation

struct LikeNotificationCellViewModel {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
}

struct FollowNotificationCellViewModel {
    let username: String
    let profilePictureURL: URL
    let isCurrentUserFollowing: Bool
}

struct CommentNotificationCellViewModel {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
}
