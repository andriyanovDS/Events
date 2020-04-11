//
//  EventNodeFlow.swift
//  Events
//
//  Created by Dmitry on 03.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import Promises

class EditEventFlow: Flow {
	var root: Presentable {
    return self.rootNavigationController
  }
	
	private lazy var rootNavigationController = UINavigationController()

	func navigate(to step: Step) -> FlowContributors {
		guard let step = step as? EventStep else {
			return .none
		}
		switch step {
		case .editEvent(let event):
			return navigateToEditEvent(event: event)
		case .editEventDidComplete:
			return .end(forwardToParentFlowWithStep: EventStep.editEventDidComplete)
		case .listModal(let title, let buttons, let onComplete):
			return navigateToListModal(title: title, buttons: buttons, onComplete: onComplete)
		case .datePickerModal(let initialDate, let mode, let onComplete):
			return navigateToDatePickerModal(
				initialDate: initialDate,
				mode: mode,
				onComplete: onComplete
			)
		case .listModalDidComplete, .datePickerModalDidComplete:
			rootNavigationController.dismiss(animated: false, completion: nil)
			return .none
		case .calendar(let withSelectedDates, let onComplete):
			return navigateToCalendarScreen(
				withSelectedDates: withSelectedDates,
				onComplete: onComplete
			)
		case .calendarDidComplete, .locationSearchDidCompete, .eventNameDidComplete:
			rootNavigationController.dismiss(animated: true, completion: nil)
			return .none
		case .eventName(let initialName, let onComplete):
			return navigateToEventNameModal(initialName: initialName, onComplete: onComplete)
		case .locationSearch(let onResult):
			return navigateToLocationSearchBar(onResult: onResult)
		default:
			return .none
		}
	}
	
	private func navigateToEditEvent(event: Event) -> FlowContributors {
		let viewModel = EditEventViewModel(event: event)
		let viewController = EditEventViewController.instantiate(with: viewModel)
		rootNavigationController.pushViewController(viewController, animated: false)
		return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
	}

  private func navigateToListModal(
    title: String,
    buttons: [ListModalButton],
    onComplete: @escaping (ListModalButton) -> Void
  ) -> FlowContributors {
    let viewModel = ListModalViewModel(buttons: buttons)
    viewModel.onResult = onComplete
		let view = ListModalView(titleText: title)
    let viewController = ListModalViewController.instantiate(with: viewModel)
		viewController.modalView = view
    viewController.modalPresentationStyle = .overFullScreen
    rootNavigationController.present(viewController, animated: false)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
	
	private func navigateToDatePickerModal(
		initialDate: Date,
		mode: UIDatePicker.Mode,
		onComplete: @escaping (Date) -> Void
	) -> FlowContributors {
		let viewModel = DatePickerModalViewModel(initialDate: initialDate, mode: mode)
		viewModel.onResult = onComplete
		let view = DatePickerModalView()
		let viewController = DatePickerModalViewController.instantiate(with: viewModel)
		viewController.modalView = view
		viewController.modalPresentationStyle = .overFullScreen
		rootNavigationController.present(viewController, animated: false)
		return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
	}

  private func navigateToCalendarScreen(
    withSelectedDates: SelectedDates,
    onComplete: @escaping (SelectedDates?) -> Void
  ) -> FlowContributors {
    let viewModel = CalendarViewModel(
      selectedDateFrom: withSelectedDates.from,
      selectedDateTo: withSelectedDates.to
    )
    let viewController = CalendarViewController.instantiate(with: viewModel)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.hero.isEnabled = true
    viewController.onResult = onComplete
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
   }

  private func navigateToLocationSearchBar(onResult: @escaping (Geocode) -> Void) -> FlowContributors {
    let viewModel = LocationSearchViewModel()
    viewModel.onResult = onResult
    let viewController = LocationSearchViewController.instantiate(with: viewModel)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.modalTransitionStyle = .coverVertical
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
	
	private func navigateToEventNameModal(
		initialName: String?,
		onComplete: @escaping (String?) -> Void
	) -> FlowContributors {
		let viewModel = EventNameViewModel(initialName: initialName)
		viewModel.onResult = onComplete
		let viewController = EventNameViewController.instantiate(with: viewModel)
		viewController.modalPresentationStyle = .overFullScreen
    viewController.modalTransitionStyle = .coverVertical
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
	}
}
