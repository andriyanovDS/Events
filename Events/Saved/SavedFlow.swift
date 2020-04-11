//
//  SavedFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow

class SavedFlow: Flow {
  var root: Presentable {
    return rootViewController
  }

  private var rootViewController = UINavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }
    switch step {
    case .saved:
      return navigateToSavedScreen()
    default:
      return .none
    }
  }

  private func navigateToSavedScreen() -> FlowContributors {
    let viewController = SavedViewController()
    rootViewController.pushViewController(viewController, animated: false)
    return .none
  }
}
