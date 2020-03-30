//
//  CratedEventsFlow.swift
//  Events
//
//  Created by Dmitry on 30.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import Promises
import Photos.PHAsset

class CreatedEventsFlow: Flow {
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
		case .createdEvents:
      return navigateToCreatedEvents()
    case .createdEventsDidComplete:
      return .end(forwardToParentFlowWithStep: EventStep.createdEventsDidComplete)
		case .alert(let title, let message, let actions):
			return navigateToAlert(title: title, message: message, actions: actions)
    default:
      return .none
    }
  }
	
	private func navigateToCreatedEvents() -> FlowContributors {
		let viewModel = CreatedEventsViewModel()
		let viewController = CreatedEventsViewController.instantiate(with: viewModel)
		rootNavigationController.pushViewController(viewController, animated: false)
		return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
	}
	
	private func navigateToAlert(
		title: String,
		message: String,
		actions: [UIAlertAction]
	) -> FlowContributors {
		let alertViewController = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)
		actions.forEach { alertViewController.addAction($0) }
		rootNavigationController.present(alertViewController, animated: false, completion: nil)
		return .none
	}
}
