//
//  CreateEventFlow.swift
//  Events
//
//  Created by Dmitry on 07.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import Promises
import Photos.PHAsset

class CreateEventFlow: Flow {
	var root: Presentable {
    return self.rootNavigationController
  }
	
	private let rootNavigationController: UINavigationController = UINavigationController()
	
	func navigate(to step: Step) -> FlowContributors {
    switch step {
    case let eventStep as EventStep:
      return handleEventStep(eventStep)
    case let createEventStep as CreateEventStep:
      return handleCreateEventStep(createEventStep)
    default:
      return .none
    }
	}

  private func handleCreateEventStep(_ step: CreateEventStep) -> FlowContributors {
    switch step {
    case
      .dateDidComplete,
      .categoryDidComplete,
      .descriptionDidComplete:
      return .none
    case .date(let onResult):
      return navigateToDateScreen(onResult: onResult)
    case .category(let onResult):
      return navigateToCategoryScreen(onResult: onResult)
    case .description(let onResult):
      return navigateToDescriptionScreen(onResult: onResult)
    }
  }

  private func handleEventStep(_ step: EventStep) -> FlowContributors {
    switch step {
    case .createEvent:
      return navigateToCreateEventScreen()
    case .locationSearch(let onResult):
      return navigateToLocationSearchBar(onResult: onResult)
    case .calendar(let withSelectedDates, let onComplete):
      return openCalendarScreen(withSelectedDates: withSelectedDates, onComplete: onComplete)
    case .imagePickerDidComplete:
      self.rootNavigationController.tabBarController?.tabBar.isHidden = false
      rootNavigationController.dismiss(animated: false, completion: nil)
      return .none
    case .locationSearchDidCompete, .calendarDidComplete:
      rootNavigationController.presentedViewController?.dismiss(animated: true, completion: nil)
      return .none
    case .hintPopupDidComplete(let nextStep):
      rootNavigationController.dismiss(animated: false, completion: nil)
      if nextStep != nil {
        return navigateToTextFormattingTips()
      }
      return .none
    case .permissionModalDidComplete, .textFormattingTipsDidComplete:
      rootNavigationController.dismiss(animated: false, completion: nil)
      return .none
    case .imagePicker(let selectedAssets, let onComplete):
      self.rootNavigationController.tabBarController?.tabBar.isHidden = true
      return navigateToImagePicker(
        selectedAssets: selectedAssets,
        onComplete: onComplete
      )
    case .permissionModal(let withType):
      return navigateToPermissionModal(with: withType)
    case .hintPopup(let popup):
      return navigateToHintPopup(hintPopup: popup)
    case .textFormattingTips:
      return navigateToTextFormattingTips()
    case .createEventDidComplete:
      return .end(forwardToParentFlowWithStep: EventStep.createEventDidComplete)
    default:
      return .none
    }
  }
	
	private func navigateToImagePicker(
    selectedAssets: [PHAsset],
    onComplete: @escaping ([PHAsset]) -> Void
  ) -> FlowContributors {
    let flow = ImagePickerFlow()
    Flows.whenReady(flow1: flow, block: { rootVC in
      rootVC.modalPresentationStyle = .overFullScreen
      self.rootNavigationController.present(rootVC, animated: false)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: flow,
      withNextStepper: OneStepper(withSingleStep: EventStep.imagePicker(
        selectedAssets: selectedAssets,
        onComplete: onComplete
        ))
      ))
  }
	
	private func navigateToHintPopup(hintPopup: HintPopup) -> FlowContributors {
    let viewModel = HintPopupViewModel()
    let viewController = HintPopupVC(hintPopup: hintPopup, viewModel: viewModel)
    viewController.modalPresentationStyle = .overCurrentContext
    viewController.isModalInPopover = true
    rootNavigationController.present(viewController, animated: false, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToTextFormattingTips() -> FlowContributors {
    let viewModel = TextFormattingTipsViewModel()
    let viewController = TextFormattingTipsVC.instantiate(with: viewModel)
    viewController.modalPresentationStyle = .overCurrentContext
    viewController.isModalInPopover = true
    rootNavigationController.present(viewController, animated: false, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
	
	private func navigateToLocationSearchBar(onResult: @escaping (Geocode) -> Void) -> FlowContributors {
    let searchBar = SearchBarViewController(nibName: nil, bundle: nil)
    let viewModel = LocationSearchViewModel(textField: searchBar.textField)
    let viewController = LocationSearchViewController(searchBar: searchBar, viewModel: viewModel)
    viewController.onResult = onResult
    viewController.modalPresentationStyle = .overFullScreen
    viewController.modalTransitionStyle = .coverVertical
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func openCalendarScreen(
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
	
  private func navigateToPermissionModal(with type: PermissionModalType) -> FlowContributors {
    let flow = PermissionModalFlow()
    Flows.whenReady(flow1: flow, block: { rootVC in
      self.rootNavigationController.present(rootVC, animated: true)
    })
    return .one(flowContributor: .contribute(
      withNextPresentable: flow,
      withNextStepper: OneStepper(withSingleStep: EventStep.permissionModal(withType: type))
      ))
  }
	
	private func navigateToCreateEventScreen() -> FlowContributors {
    let createEventViewModel = CreateEventViewModel()
    let createEventViewController = CreateEventViewController.instantiate(with: createEventViewModel)
    rootNavigationController.pushViewController(createEventViewController, animated: false)

    let locationViewModel = LocationViewModel()
    let locationViewController = LocationViewController.instantiate(with: locationViewModel)
    locationViewController.onResult = { geocode in
      createEventViewModel.locationDidSelected(geocode: geocode)
    }
    locationViewController.onBackAction = {
      createEventViewModel.onClose()
    }
    rootNavigationController.pushViewController(locationViewController, animated: false)

    return .multiple(flowContributors: [
      .contribute(
        withNextPresentable: createEventViewController,
        withNextStepper: createEventViewModel,
        allowStepWhenNotPresented: true
      ),
      .contribute(
        withNextPresentable: locationViewController,
        withNextStepper: locationViewModel,
        allowStepWhenNotPresented: false
      )
    ])
  }

  private func navigateToDateScreen(onResult: @escaping (DateScreenResult) -> Void) -> FlowContributors {
    let viewModel = DateViewModel()
    let viewController = DateViewController.instantiate(with: viewModel)
    viewController.onResult = onResult
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToCategoryScreen(onResult: @escaping (CategoryId) -> Void) -> FlowContributors {
    let viewModel = CategoryViewModel()
    let viewController = CategoryViewController.instantiate(with: viewModel)
    viewController.onResult = onResult
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToDescriptionScreen(onResult: @escaping ([DescriptionWithAssets]) -> Void) -> FlowContributors {
    let viewModel = DescriptionViewModel()
    let viewController = DescriptionViewController.instantiate(with: viewModel)
    viewController.onResult = onResult
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
}
