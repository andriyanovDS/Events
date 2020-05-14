//
//  PermissionModalFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 19/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import Foundation

class PermissionModalFlow: Flow {
  var root: Presentable {
    return self.rootNavigationController
  }

  private var rootNavigationController = UINavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }
    switch step {
    case .permissionModal(let withType):
      return navigateToPermissionModal(with: withType)
    case .permissionModalDidComplete:
      return .end(forwardToParentFlowWithStep: EventStep.permissionModalDidComplete)
    default:
      return .none
    }
  }

  func navigateToPermissionModal(with type: PermissionModalType) -> FlowContributors {
    let viewModel = PermissionModalViewModel()
    let viewController = PermissionModalViewController(type: type, viewModel: viewModel)
    viewController.modalPresentationStyle = .overCurrentContext
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
}
