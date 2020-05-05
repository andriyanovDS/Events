//
//  HomeFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import Hero

class HomeFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }

  private var rootViewController = UINavigationController()
  private var eventViewControllerTransitionDelegate: EventViewControllerTransitionDelegate?

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }
    switch step {
    case .home:
      return navigateToHomeScreen()
    case .calendar(let withSelectedDates, let onComplete):
      return openCalendarScreen(selectedDates: withSelectedDates, onComplete: onComplete)
    case .calendarDidComplete, .eventDidComplete:
      rootViewController.dismiss(animated: true, completion: nil)
      return .none
    case .locationSearch(let onResult):
      return openLocationSearch(onResult: onResult)
    case .locationSearchDidCompete:
      rootViewController.dismiss(animated: true, completion: nil)
      return .none
    case .event(let event, let sharedImage, let sharedCardInfo):
      guard let info = sharedCardInfo else {
        assertionFailure("Provide shared card info for transition animation")
        return .none
      }
      return openEvent(event, sharedImage: sharedImage, sharedCardInfo: info)
    default:
      return .none
    }
  }

  private func navigateToHomeScreen() -> FlowContributors {
    let viewController = RootScreenModuleConfigurator().configure()
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: viewController.viewModel
      ))
  }

  private func openCalendarScreen(
    selectedDates: SelectedDates,
    onComplete: @escaping (SelectedDates?) -> Void
  ) -> FlowContributors {
    let viewModel = CalendarViewModel()
    let dataSource = CalendarDataSource(selectedDates: selectedDates)
    let viewController = CalendarViewController(dataSource: dataSource, viewModel: viewModel)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.isModalInPopover = true
    viewController.onResult = onComplete
    viewController.hero.isEnabled = true
    rootViewController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func openLocationSearch(onResult: @escaping (Geocode) -> Void) -> FlowContributors {
    let viewModel = LocationSearchViewModel()
		viewModel.onResult = onResult
		let viewController = LocationSearchViewController.instantiate(with: viewModel)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.modalTransitionStyle = .coverVertical
    rootViewController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func openEvent(
    _ event: Event,
    sharedImage: UIImage?,
    sharedCardInfo: SharedEventCardInfo
  ) -> FlowContributors {
    let viewController = EventModuleConfigurator().configure(
      with: event,
      sharedImage: sharedImage
    )
    viewController.modalPresentationStyle = .overFullScreen
    let driver = EventTransitionDriver(sharedViewOrigin: sharedCardInfo.origin) {[weak viewController] in
      viewController?.dismiss(animated: true, completion: nil)
    }
    eventViewControllerTransitionDelegate = EventViewControllerTransitionDelegate(
      sharedCardInfo: sharedCardInfo,
      transitionDriver: driver
    ) {[weak self] in
      self?.eventViewControllerTransitionDelegate = nil
    }
    viewController.transitioningDelegate = eventViewControllerTransitionDelegate
    viewController.transitionDriver = driver
    rootViewController.present(viewController, animated: true)
    return .one(flowContributor: .contribute(
      withNextPresentable: viewController,
      withNextStepper: viewController.viewModel,
      allowStepWhenNotPresented: false
      ))
  }
}
