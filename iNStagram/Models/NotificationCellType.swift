//
//  NotificationCellType.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 24.02.2024.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}
