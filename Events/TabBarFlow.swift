//
//  TabBarFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import UIKit

class TabBarFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }

  private let rootViewController = UITabBarController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }
    switch step {
    case .home:
      return navigateToHomeScreen()
    default:
      return .none
    }
  }

  private func navigateToHomeScreen() -> FlowContributors {
    let
      homeFlow = HomeFlow(),
      savedFlow = SavedFlow(),
      eventsFlow = EventsFlow(),
      profileFlow = ProfileFlow()

    Flows.whenReady(
      flow1: homeFlow,
      flow2: savedFlow,
      flow3: eventsFlow,
      flow4: profileFlow,
      block: { [unowned self] (homeVC, savedVC, eventsVC, profileVC) in
        let rootScreenTabBarItem = self.getTabBarItem(forState: .home)
        let savedScreenTabBarItem = self.getTabBarItem(forState: .saved)
        let eventsScreenTabBarItem = self.getTabBarItem(forState: .events)
        let profileScreenTabBarItem = self.getTabBarItem(forState: .profile)

        homeVC.tabBarItem = rootScreenTabBarItem
        eventsVC.tabBarItem = eventsScreenTabBarItem
        savedVC.tabBarItem = savedScreenTabBarItem
        profileVC.tabBarItem = profileScreenTabBarItem
        
        self.rootViewController.setViewControllers([homeVC, savedVC, eventsVC, profileVC], animated: false)
    })

    return .multiple(flowContributors: [
      .contribute(withNextPresentable: homeFlow, withNextStepper: OneStepper(withSingleStep: EventStep.home)),
      .contribute(withNextPresentable: savedFlow, withNextStepper: OneStepper(withSingleStep: EventStep.saved)),
      .contribute(withNextPresentable: eventsFlow, withNextStepper: OneStepper(withSingleStep: EventStep.events)),
      .contribute(withNextPresentable: profileFlow, withNextStepper: OneStepper(withSingleStep: EventStep.profile))
      ])
  }

  private func getTabBarItem(forState state: TabBarState) -> UITabBarItem {
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

  private func setupTabBar() {
    rootViewController.tabBar.style({ v in
      v.barTintColor = .white
      _ = v.addBorder(toSide: .top, withColor: UIColor.gray800().cgColor, andThickness: 1)
      v.tintColor = UIColor.blue()
      v.unselectedItemTintColor = UIColor.gray800()
    })
  }
}

enum TabBarState {
  case home, profile, saved, events
}
