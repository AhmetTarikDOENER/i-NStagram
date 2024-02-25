//
//  NotificationCellViewModels.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 24.02.2024.
//

import Foundation

struct LikeNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
    let dateString: String
}

struct FollowNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureURL: URL
    let isCurrentUserFollowing: Bool
    let dateString: String
}

struct CommentNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureURL: URL
    let postURL: URL
    let dateString: String
}
