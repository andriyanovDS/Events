//
//  HomeFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow

class HomeFlow: Flow {
  var root: Presentable {
    return self.rootViewController
  }

  private var rootViewController = UINavigationController()

  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? EventStep else {
      return .none
    }
    switch step {
    case .home:
      return navigateToHomeScreen()
    case .calendar(let withSelectedDates, let onComplete):
      return openCalendarScreen(selectedDates: withSelectedDates, onComplete: onComplete)
    case .calendarDidComplete:
      rootViewController.dismiss(animated: false, completion: nil)
      return .none
    case .locationSearch(let onResult):
      return openLocationSearch(onResult: onResult)
    case .locationSearchDidCompete:
      rootViewController.dismiss(animated: true, completion: nil)
      return .none
    default:
      return .none
    }
  }

  private func navigateToHomeScreen() -> FlowContributors {
    let viewModel = RootScreenViewModel()
    let viewController = RootScreenViewController.instantiate(with: viewModel)
    rootViewController.pushViewController(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func openCalendarScreen(
    selectedDates: SelectedDates,
    onComplete: @escaping (SelectedDates) -> Void
    ) -> FlowContributors {

    let viewModel = CalendarViewModel(
      selectedDateFrom: selectedDates.from,
      selectedDateTo: selectedDates.to
    )
    let viewController = CalendarViewController.instantiate(with: viewModel)
    viewController.modalPresentationStyle = .overCurrentContext
    viewController.isModalInPopover = true
    viewController.onResult = onComplete
    rootViewController.present(viewController, animated: false, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func openLocationSearch(onResult: @escaping (Geocode) -> Void) -> FlowContributors {
    let searchBarViewController = SearchBarViewController(nibName: nil, bundle: nil)
    let viewModel = LocationSearchViewModel(textField: searchBarViewController.textField)
    let viewController = LocationSearchViewController(searchBar: searchBarViewController, viewModel: viewModel)
    viewController.onResult = onResult
    viewController.modalPresentationStyle = .overFullScreen
    viewController.modalTransitionStyle = .coverVertical
    rootViewController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
}
