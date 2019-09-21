//
//  ProfileFlow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 18/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
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
    print("event", step)
    switch step {
    case .profile:
      return navigateToProfileScreen()
    case .login:
      return navigateToLoginScreen()
    case .locationSearch(let onResult):
      return navigateToLocationSearchBar(onResult: onResult)
    case .userDetails(let user):
      return navigateToUserDetails(user: user)
    case .imagePickerDidComplete:
      self.rootNavigationController.tabBarController?.tabBar.isHidden = false
       rootNavigationController.dismiss(animated: false, completion: nil)
      return .none
    case .userDetailsDidComplete, .locationSearchDidCompete:
      rootNavigationController.dismiss(animated: true, completion: nil)
      return .none
    case .calendarDidComplete, .permissionModalDidComplete, .hintPopupDidComplete:
      rootNavigationController.dismiss(animated: false, completion: nil)
      return .none
    case .imagePicker(let onComplete):
      return navigateToImagePicker(onComplete: onComplete)
    case .permissionModal(let withType):
      return navigateToPermissionModal(with: withType)
    case .hintPopup(let popup):
      return navigateToHintPopup(hintPopup: popup)
    case .createEvent:
      return navigateToCreateEventScreen()
    case .createEventDidComplete:
      rootNavigationController.popViewController(animated: true)
      return .none
    default:
      return .none
    }
  }

  func navigateToUserDetails(user: User) -> FlowContributors {
    let viewModel = UserDetailsViewModel()
    let viewController = UserDetailsViewController(user: user, viewModel: viewModel)
    viewController.modalTransitionStyle = .coverVertical
    viewController.modalPresentationStyle = .overCurrentContext
    rootNavigationController.present(
      viewController,
      animated: true,
      completion: nil
    )
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  func navigateToCreateEventScreen() -> FlowContributors {
    let viewModel = CreateEventViewModel()
    let viewController = CreateEventViewController.instantiate(with: viewModel)
    rootNavigationController.pushViewController(viewController, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  func navigateToLocationSearchBar(onResult: @escaping (Geocode) -> Void) -> FlowContributors {
    let searchBar = SearchBarViewController(nibName: nil, bundle: nil)
    let viewModel = LocationSearchViewModel(textField: searchBar.textField)
    let viewController = LocationSearchViewController(searchBar: searchBar, viewModel: viewModel)
    viewController.onResult = onResult
    viewController.modalPresentationStyle = .overFullScreen
    viewController.modalTransitionStyle = .coverVertical
    rootNavigationController.present(viewController, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
  }

  private func openCalendarScreen(onComplete: @escaping (SelectedDates) -> Void) -> FlowContributors {
     let viewModel = CalendarViewModel(
       selectedDateFrom: nil,
       selectedDateTo: nil
     )
     let viewController = CalendarViewController.instantiate(with: viewModel)
     viewController.modalPresentationStyle = .overCurrentContext
     viewController.isModalInPopover = true
     viewController.onResult = onComplete
     rootNavigationController.present(viewController, animated: false, completion: nil)
     return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
   }

  func navigateToHintPopup(hintPopup: HintPopup) -> FlowContributors {
    let viewModel = HintPopupViewModel()
    let viewController = HintPopupVC(hintPopup: hintPopup, viewModel: viewModel)
    viewController.modalPresentationStyle = .overCurrentContext
    viewController.isModalInPopover = true
    rootNavigationController.present(viewController, animated: false, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
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

  func navigateToImagePicker(onComplete: @escaping ([UIImage]) -> Void) -> FlowContributors {
    let viewModel = ImagePickerViewModel(onResult: onComplete)
    let viewController = ImagePickerVC(viewModel: viewModel)
    viewController.modalTransitionStyle = .coverVertical
    viewController.modalPresentationStyle = .overCurrentContext
    self.rootNavigationController.tabBarController?.tabBar.isHidden = true
    rootNavigationController.present(viewController, animated: false, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewModel))
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
}