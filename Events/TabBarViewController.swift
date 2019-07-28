//
//  TabBarViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import SwiftIconFont

class TabBarViewController: UITabBarController {
    var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
    }
    
    func setupViewControllers() {
        let rootScreenNavigationController = RootScreenNavigationController()
        let profileScreenViewController = ProfileScreenViewController()
        let savedViewController = SavedViewController()
        let eventsViewController = EventsViewController()
        
        let rootScreenTabBarItem = getTabBarItem(forState: .home)
        let savedScreenTabBarItem = getTabBarItem(forState: .saved)
        let eventsScreenTabBarItem = getTabBarItem(forState: .events)
        let profileScreenTabBarItem = getTabBarItem(forState: .profile)
        
        rootScreenNavigationController.tabBarItem = rootScreenTabBarItem
        savedViewController.tabBarItem = savedScreenTabBarItem
        eventsViewController.tabBarItem = eventsScreenTabBarItem
        profileScreenViewController.tabBarItem = profileScreenTabBarItem
        
        viewControllers = [
            rootScreenNavigationController,
            savedViewController,
            eventsViewController,
            profileScreenViewController
        ]
    }
    
    func getTabBarItem(forState state: TabBarState) -> UITabBarItem {
        let tabBarItem = UITabBarItem()
        
        switch state {
        case .home:
            tabBarItem.icon(
                from: .materialIcon,
                code: "home",
                iconColor: UIColor.gray800(),
                imageSize: CGSize(width: 30, height: 30),
                ofSize: 30
            )
        case .profile:
            tabBarItem.icon(
                from: .materialIcon,
                code: "person.outline",
                iconColor: UIColor.gray800(),
                imageSize: CGSize(width: 30, height: 30),
                ofSize: 30
            )
        case .saved:
            tabBarItem.icon(
                from: .materialIcon,
                code: "favorite.border",
                iconColor: UIColor.gray800(),
                imageSize: CGSize(width: 30, height: 30),
                ofSize: 30
            )
        case .events:
            tabBarItem.icon(
                from: .materialIcon,
                code: "event",
                iconColor: UIColor.gray800(),
                imageSize: CGSize(width: 30, height: 30),
                ofSize: 30
            )
        }
        return tabBarItem
    }
    
    func setupTabBar() {
        tabBar.barTintColor = .white
        tabBar.addBorder(toSide: .top, withColor: UIColor.gray800().cgColor, andThickness: 1)
        tabBar.tintColor = UIColor.blue()
        tabBar.unselectedItemTintColor = UIColor.gray800()
    }
}

enum TabBarState {
    case home, profile, saved, events
}
