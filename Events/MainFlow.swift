//
//  MainFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import RxSwift
import RxCocoa

class MainFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }

  private lazy var rootViewController: UINavigationController = {
    let viewController = UINavigationController()
		viewController.view.backgroundColor = .background
    viewController.setNavigationBarHidden(true, animated: false)
    return viewController
  }()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }

    switch step {
    case .login:
      return navigateToLoginScreen()
    case .home:
      return navigateToHomeScreen()
    default: return .none
    }
  }

  private func navigateToLoginScreen() -> FlowContributors {
    let loginFlow = LoginFlow()
    Flows.whenReady(flow1: loginFlow, block: { [unowned self] root in
      DispatchQueue.main.async {
        root.modalPresentationStyle = .fullScreen
				root.hero.modalAnimationType = .fade
				root.hero.isEnabled = true
        self.rootViewController.present(root, animated: true)
      }
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: loginFlow,
      withNextStepper: OneStepper(withSingleStep: EventStep.login))
    )
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

class MainStepper: Stepper {
  let steps = PublishRelay<Step>()

  func readyToEmitSteps() {
		CurrentUser.shared.userOptionalPromise
			.then {[weak self] user in
				self?.steps.accept(user.fold(
					none: EventStep.login,
					some: { _ in EventStep.home }
				))
			}
			.catch { print($0.localizedDescription) }
  }
}
