//
//  ProfileHeaderViewModel.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 25.02.2024.
//

import Foundation

enum ProfileButtonType {
    case edit
    case follow(isFollowing: Bool)
}

struct ProfileHeaderViewModel {
    let profilePictureURL: URL?
    let followerCount: Int
    let followingCount: Int
    let postCount: Int
    let buttonType: ProfileButtonType
    let bio: String?
    let name: String?
}
