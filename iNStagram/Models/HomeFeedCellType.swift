//
//  HomeFeedCellType.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 20.02.2024.
//

import Foundation

enum HomeFeedCellType {
    case poster(viewModel: PosterCollectionViewCellViewModel)
    case post(viewModel: PostCollectionViewCellViewModel)
    case action(viewModel: PostActionsCollectionViewCellViewModel)
    case likeCount(viewModel: PostLikesCollectionViewCellViewModel)
    case caption(viewModel: PostCaptionCollectionViewCellViewModel)
    case timestamp(viewModel: PostDateTimeCollectionViewCellViewModel)
}
