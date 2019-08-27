//
//  ProfileCoordinator.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class ProfileScreenCoordinator: MainCoordinator,
  UserDetailsScreenCoordinator,
  LocationSearchCoordinator {
  
  func openUserDetails(user: User) {
    let userDetailsViewController = UserDetailsViewController(user: user, coordinator: self)
    userDetailsViewController.modalTransitionStyle = .coverVertical
    userDetailsViewController.modalPresentationStyle = .overCurrentContext
    navigationController.present(
      userDetailsViewController,
      animated: true,
      completion: nil
    )
  }
  
  func userDetailsDidSubmit() {
    navigationController.dismiss(animated: true, completion: nil)
  }
  
  func openCreateEventScreen() {
    let createEventViewController = CreateEventViewController()
    createEventViewController.coordinator = self
    navigationController.pushViewController(createEventViewController, animated: true)
  }
  
  override func start() {
    
  }
}

extension ProfileScreenCoordinator: CreateEventCoordinator {
  func openLocationSearchBar(onResult: @escaping (Geocode) -> Void) {
    let viewController = LocationSearchViewController()
    viewController.coordinator = self
    viewController.onClose = onResult
    viewController.modalPresentationStyle = .overFullScreen
    viewController.modalTransitionStyle = .coverVertical
    navigationController.present(viewController, animated: true, completion: nil)
  }

  func onLocationDidSelected() {
    self.navigationController.dismiss(animated: true, completion: nil)
  }
  
  func openCameraAccessModal(type: PermissionModalType, delegate: UserDetailsViewModelDelegate) {
    let permissionModal = PermissionModalScreenViewController(modalType: .photo)
    delegate.present(permissionModal, animated: true, completion: nil)
  }
  
  func openCalendar(onResult: @escaping (SelectedDates) -> Void) {
    let calendarViewController = CalendarViewController()
    calendarViewController.modalPresentationStyle = .overCurrentContext
    calendarViewController.isModalInPopover = true
    calendarViewController.onResult = onResult
    navigationController.present(calendarViewController, animated: false, completion: nil)
  }

  func onDateDidSelected() {
    self.navigationController.dismiss(animated: true, completion: nil)
  }

  func openHintPopup(hintPopup: HintPopup) {
    let viewController = HintPopupVC(hintPopup: hintPopup)
    viewController.coordinator = self
    viewController.modalPresentationStyle = .overCurrentContext
    viewController.isModalInPopover = true
    navigationController.present(viewController, animated: false, completion: nil)
  }
}

extension ProfileScreenCoordinator: HintPopupViewCoordinator {

  func openTextFormattingTips() {
    let viewController = TextFormattingTipsVC()
    viewController.coordinator = self
    navigationController.present(viewController, animated: true, completion: nil)
  }

  func closePopup(onComplete: (() -> Void)?) {
     self.navigationController.dismiss(animated: false, completion: onComplete)
  }
}

extension ProfileScreenCoordinator: TextFormattingTipsCoordinator {
  func closeTextFormattingTips() {
    self.navigationController.dismiss(animated: true, completion: nil)
  }
}
