//
//  iNStagramTests.swift
//  iNStagramTests
//
//  Created by Ahmet Tarik DÖNER on 27.02.2024.
//

import XCTest
@testable import iNStagram

final class iNStagramTests: XCTestCase {

    func test_notification_id_creation() {
        let first = NotificationsManager.newIdentifier()
        let second = NotificationsManager.newIdentifier()
        XCTAssertNotEqual(first, second)
    }
}
