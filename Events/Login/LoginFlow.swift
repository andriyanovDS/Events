//
//  LoginFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow

class LoginFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }

  private let rootViewController = UINavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }

    switch step {
    case .login:
      return navigateToLoginScreen()
    case .home:
      return navigateToHomeScreen()
    default:
      return .none
    }
  }

  private func navigateToLoginScreen() -> FlowContributors {
    let viewModel = LoginViewModel()
    let viewController = LoginViewController(viewModel: viewModel)
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToHomeScreen() -> FlowContributors {
    let tabBarFlow = TabBarFlow()
    Flows.whenReady(flow1: tabBarFlow, block: { [unowned self] root in
      self.rootViewController.pushViewController(root, animated: false)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: tabBarFlow,
      withNextStepper: OneStepper(withSingleStep: EventStep.home))
    )
  }
}
