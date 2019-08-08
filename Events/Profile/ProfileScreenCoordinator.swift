//
//  ProfileCoordinator.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class ProfileScreenCoordinator:
  MainCoordinator,
  UserDetailsScreenCoordinator,
  CreateEventCoordinator,
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
  
  override func start() {
    
  }
}
