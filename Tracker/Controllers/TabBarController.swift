//
//  TabBarController.swift
//  Tracker
//
//  Created by Anton Rachkov on 29.09.2026.
//

import UIKit

final class TabBarController: UITabBarController {
    private let colors = Colors()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    private func setupAppearance() {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = colors.viewBackgroundColor
            appearance.shadowColor = colors.tabBarSeparatorColor
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    func setupTabs() {
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers.title", comment: ""),
            image: UIImage(systemName: "record.circle.fill"),
            tag: 0
        )
        
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics.title", comment: ""),
            image: UIImage(systemName: "hare.fill"),
            tag: 1
        )
        self.viewControllers = [trackersNavigationController, statisticViewController]
    }
}
