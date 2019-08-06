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
    LocationSearchCoordinator, ModalScreenViewCoordinator {

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
    func openPermissionModal(type: ModalType) {
        let permissionModal = ModalScreenViewController(modalType: .permissionModal)
        permissionModal.coordinator = self
        navigationController.present(permissionModal, animated: false, completion: nil)
    }
    func closeModal() {
        navigationController.dismiss(animated: true, completion: nil)
    }
    func openLocationSearchBar(onResult: @escaping (Geocode) -> Void) {
        let viewController = LocationSearchViewController()
        viewController.coordinator = self
        viewController.onClose = onResult
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .coverVertical
        navigationController.present(viewController, animated: false, completion: nil)
    }

    func onLocationDidSelected() {
        self.navigationController.dismiss(animated: true, completion: nil)
    }

    override func start() {

    }
}
