//
//  TabBarController.swift
//  Tracker
//
//  Created by Anton Rachkov on 29.09.2026.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
            super.viewDidLoad()
            setupTabs()
        }
    func setupTabs() {
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
                    title: "Трекеры",
                    image: UIImage(systemName: "record.circle.fill"),
                    tag: 0
                )
        
        let statisticViewController = StatisticViewController()
                statisticViewController.tabBarItem = UITabBarItem(
                    title: "Статистика",
                    image: UIImage(systemName: "hare.fill"),
                    tag: 1
                )
        self.viewControllers = [trackersNavigationController, statisticViewController]
    }
}
