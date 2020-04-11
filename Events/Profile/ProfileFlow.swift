//
//  ProfileFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 18/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import Photos
import Hero
import Foundation

class ProfileFlow: Flow {
  var root: Presentable {
    return self.rootNavigationController
  }

  private lazy var rootNavigationController: UINavigationController = {
    let controller = UINavigationController()
    controller.setNavigationBarHidden(true, animated: false)
    return controller
  }()
	
	func navigate(to step: Step) -> FlowContributors {
		guard let step = step as? EventStep else {
			return .none
		}
		switch step {
		case .profile:
			return navigateToProfileScreen()
		case .login:
			return navigateToLoginScreen()
		case .userDetails(let user):
			return navigateToUserDetails(user: user)
		case .userDetailsDidComplete:
			rootNavigationController.dismiss(animated: true, completion: nil)
			return .none
		case .permissionModalDidComplete:
			rootNavigationController.dismiss(animated: false, completion: nil)
			return .none
		case .permissionModal(let withType):
			return navigateToPermissionModal(with: withType)
		case .createEvent:
			return navigateToCreateEventScreen()
		case .createEventDidComplete, .createdEventsDidComplete:
			rootNavigationController.dismiss(animated: true, completion: nil)
			return .none
		case .createdEvents:
			return navigateToCreatedEvents()
		default:
			return .none
		}
  }

  func navigateToUserDetails(user: User) -> FlowContributors {
		let viewModel = UserDetailsViewModel(user: user)
		let viewController = UserDetailsViewController.instantiate(with: viewModel)
    viewController.modalTransitionStyle = .coverVertical
    viewController.modalPresentationStyle = .overFullScreen
    rootNavigationController.present(
      viewController,
      animated: true,
      completion: nil
    )
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  func navigateToCreateEventScreen() -> FlowContributors {
		let createEventFlow = CreateEventFlow()
    Flows.whenReady(flow1: createEventFlow, block: {[unowned self] root in
      root.modalPresentationStyle = .fullScreen
      root.hero.modalAnimationType = .selectBy(
        presenting: .push(direction: .left),
        dismissing: .push(direction: .right)
      )
      root.hero.isEnabled = true
      self.rootNavigationController.present(root, animated: true)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: createEventFlow,
      withNextStepper: OneStepper(withSingleStep: EventStep.createEvent))
    )
  }

  func navigateToPermissionModal(with type: PermissionModalType) -> FlowContributors {
    let flow = PermissionModalFlow()
    Flows.whenReady(flow1: flow, block: { rootVC in
      self.rootNavigationController.present(rootVC, animated: true)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: flow,
      withNextStepper: OneStepper(withSingleStep: EventStep.permissionModal(withType: type))
      ))
  }

  private func navigateToLoginScreen() -> FlowContributors {
    let loginFlow = LoginFlow()
    Flows.whenReady(flow1: loginFlow, block: { [unowned self] root in
      root.modalPresentationStyle = .fullScreen
      self.rootNavigationController.present(root, animated: false)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: loginFlow,
      withNextStepper: OneStepper(withSingleStep: EventStep.login))
    )
  }

  func navigateToProfileScreen() -> FlowContributors {
    let viewModel = ProfileScreenViewModel()
    let viewController = ProfileScreenViewController.instantiate(with: viewModel)
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
	
  func navigateToCreatedEvents() -> FlowContributors {
		let createdEventsFlow = CreatedEventsFlow()
    Flows.whenReady(flow1: createdEventsFlow, block: {[unowned self] root in
      root.modalPresentationStyle = .fullScreen
			root.modalTransitionStyle = .coverVertical
      self.rootNavigationController.present(root, animated: true)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: createdEventsFlow,
      withNextStepper: OneStepper(withSingleStep: EventStep.createdEvents))
    )
  }
}
