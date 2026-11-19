//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Anton Rachkov on 28.09.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testTrackersViewControllerLight() {
        let vc = TrackersViewController()
        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .light))
        )
    }

    func testTrackersViewControllerDark() {
        let vc = TrackersViewController()
        assertSnapshot(
            of: vc,
            as: .image(traits: .init(userInterfaceStyle: .dark))
        )
    }
}
