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
		case .editEvent(let event):
			return navigateToEditEvent(event: event)
		case .editEventDidComplete:
			rootNavigationController.dismiss(animated: true, completion: nil)
			return .none
		case .alert(let title, let message, let actions):
			return navigateToAlert(title: title, message: message, actions: actions)
		case .event(let event, let sharedImage, _):
			return navigateToEvent(event, sharedImage: sharedImage)
		case .eventDidComplete:
			rootNavigationController.dismiss(animated: true, completion: nil)
			return .none
		default:
			return .none
		}
	}
	
	private func navigateToCreatedEvents() -> FlowContributors {
    let viewController = CreatedEventsConfigurator().configure()
		rootNavigationController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: viewController.viewModel
      ))
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
	
	private func navigateToEditEvent(event: Event) -> FlowContributors {
		let flow = EditEventFlow()
		Flows.whenReady(flow1: flow, block: {[unowned self] root in
      root.modalPresentationStyle = .fullScreen
			root.modalTransitionStyle = .coverVertical
      self.rootNavigationController.present(root, animated: true)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: flow,
			withNextStepper: OneStepper(withSingleStep: EventStep.editEvent(event: event)))
    )
	}
	
	private func navigateToEvent(_ event: Event, sharedImage: UIImage?) -> FlowContributors {
    let viewController = EventModuleConfigurator().configure(
      with: event,
      sharedImage: sharedImage
    )
		viewController.modalPresentationStyle = .overFullScreen
		rootNavigationController.present(viewController, animated: true)
		return .one(flowContributor: .contribute(
			withNextPresentable: viewController,
      withNextStepper: viewController.viewModel
			))
  }
}
