//
//  StoriesViewModel.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 27.02.2024.
//

import UIKit

struct StoriesViewModel {
    let stories: [Story]
}

struct Story {
    let username: String
    let image: UIImage?
}
