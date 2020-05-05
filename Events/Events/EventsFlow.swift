//
//  EventsFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow

class EventsFlow: Flow {
  var root: Presentable {
    return rootNavigationController
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
		case .events:
			return navigateToEventsScreen()
		case .event(let event, _, _):
			return navigateToEvent(event)
		case .home:
			return navigateToHomeScreen()
		case .eventDidComplete(let userEvent):
			let presentingVC = rootNavigationController.presentedViewController
			let topVC = rootNavigationController.topViewController
			if !userEvent.isJoin,
				let eventVC = presentingVC as? EventViewController,
				let eventListVC = topVC as? EventsViewController {
				
				eventVC.disableSharedAnimationOnViewDisappear()
				eventListVC.viewModel?.removeEvent(with: userEvent.eventId)
			}
			rootNavigationController.dismiss(animated: true, completion: nil)
			return .none
		default:
			return .none
		}
	}

  private func navigateToEventsScreen() -> FlowContributors {
		let viewModel = EventsViewModel()
		let viewController = EventsViewController.instantiate(with: viewModel)
    rootNavigationController.pushViewController(viewController, animated: false)
		return .one(flowContributor: .contribute(
			withNextPresentable: viewController,
			withNextStepper: viewModel
			))
  }
	
	private func navigateToEvent(_ event: Event) -> FlowContributors {
    let viewController = EventModuleConfigurator().configure(
      with: event,
      sharedImage: nil
    )
    viewController.modalPresentationStyle = .fullScreen
    viewController.modalTransitionStyle = .coverVertical
    rootNavigationController.present(viewController, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: viewController.viewModel,
      allowStepWhenNotPresented: false
      ))
  }
	
	private func navigateToHomeScreen() -> FlowContributors {
		if let parentController = rootNavigationController.parent as? UITabBarController {
			parentController.selectedIndex = 0
		}
		return .none
	}
}
