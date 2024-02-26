//
//  SettingsModels.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 26.02.2024.
//

import UIKit

struct SettingsSection {
    let title: String
    let options: [SettingOptions]
}

struct SettingOptions {
    let title: String
    let image: UIImage?
    let color: UIColor
    let handler: (() -> Void)
}
