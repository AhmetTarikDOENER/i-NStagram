//
//  AnalyticsManager.swift
//  iNStagram
//
//  Created by Ahmet Tarik DÖNER on 17.02.2024.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private init() {}
    
    func  logEvent() {
        Analytics.logEvent("", parameters: [:])
    }
}
