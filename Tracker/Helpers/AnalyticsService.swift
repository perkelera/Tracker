//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Anton Rachkov on 19.11.2026.
//

import Foundation
import AppMetricaCore

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "c5a32e48-cc37-49c2-af11-94315cea8731") else { return }
        AppMetrica.activate(with: configuration)
    }

    func report(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item = item {
            params["item"] = item.rawValue
        }

        print("📊 Analytics event: \(params)")
        AppMetrica.reportEvent(name: event.rawValue, parameters: params) { error in
            print("Analytics error: \(error.localizedDescription)")
        }
    }
}
