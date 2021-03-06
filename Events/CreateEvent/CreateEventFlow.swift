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
		.locationDidComplete,
		.descriptionDidComplete:
			return .none
		case .location(let onResult):
			return navigateToLocationScreen(onResult: onResult)
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
			return openCalendarScreen(with: withSelectedDates, onComplete: onComplete)
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
    let viewModel = LocationSearchViewModel(onResult: onResult)
		let viewController = LocationSearchViewController.instantiate(with: viewModel)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.modalTransitionStyle = .coverVertical
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func openCalendarScreen(
    with selectedDates: SelectedDates,
    onComplete: @escaping (SelectedDates?) -> Void
  ) -> FlowContributors {
    let viewModel = CalendarViewModel(onResult: onComplete)
    let dataSource = CalendarDataSource(selectedDates: selectedDates)
    let viewController = CalendarViewController(dataSource: dataSource, viewModel: viewModel)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.hero.isEnabled = true
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

    let startViewModel = StartViewModel(onResult: { data in
      createEventViewModel.eventStartDataDidSelected(data: data)
    })
    let startViewController = StartViewController.instantiate(with: startViewModel)
    startViewController.onBackAction = {
      createEventViewModel.onClose()
    }
    rootNavigationController.pushViewController(startViewController, animated: false)

    return .multiple(flowContributors: [
      .contribute(
        withNextPresentable: createEventViewController,
        withNextStepper: createEventViewModel,
        allowStepWhenNotPresented: true
      ),
      .contribute(
        withNextPresentable: startViewController,
        withNextStepper: startViewModel,
        allowStepWhenNotPresented: false
      )
    ])
  }
	
	private func navigateToLocationScreen(onResult: @escaping (Geocode) -> Void) -> FlowContributors {
    let viewModel = LocationViewModel(onResult: onResult)
    let viewController = LocationViewController.instantiate(with: viewModel)
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToDateScreen(onResult: @escaping (DateScreenResult) -> Void) -> FlowContributors {
    let viewModel = DateViewModel(onResult: onResult)
    let viewController = DateViewController.instantiate(with: viewModel)
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToCategoryScreen(onResult: @escaping (CategoryId) -> Void) -> FlowContributors {
    let viewModel = CategoryViewModel(onResult: onResult)
    let viewController = CategoryViewController.instantiate(with: viewModel)
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func navigateToDescriptionScreen(onResult: @escaping ([DescriptionWithAssets]) -> Void) -> FlowContributors {
    let viewModel = DescriptionViewModel(onResult: onResult)
    let viewController = DescriptionViewController.instantiate(with: viewModel)
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }
}
