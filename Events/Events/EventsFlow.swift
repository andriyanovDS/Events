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
		case .event(let event, let author, let sharedImage):
			return navigateToEvent(
				event,
				author: author,
				sharedImage: sharedImage
			)
		case .home:
			return navigateToHomeScreen()
		case .eventDidComplete:
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
	
	private func navigateToEvent(_ event: Event, author: User, sharedImage: UIImage?) -> FlowContributors {
		let viewModel = EventViewModel(event: event, author: author)
    let viewController = EventViewController(viewModel: viewModel, sharedImage: sharedImage)
    viewController.modalPresentationStyle = .overFullScreen
		viewController.isModalInPopover = true
    viewController.hero.isEnabled = true
    rootNavigationController.present(viewController, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: viewModel,
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
