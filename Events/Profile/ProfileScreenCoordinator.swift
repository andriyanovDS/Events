//
//  ProfileCoordinator.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class ProfileScreenCoordinator: MainCoordinator, UserDetailsScreenCoordinator, PopupWindowCoordinator {
    
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
    
    func openPermissionPopup(title: String, buttonText: String) {
        let popupWindow = PopupWindowViewController()
        popupWindow.setupView(titleLabel: title, image: nil, desciption: nil, buttonLabelText: buttonText)
        popupWindow.coordinator = self
        popupWindow.modalPresentationStyle = .overCurrentContext
        popupWindow.isModalInPopover = true
        navigationController.present(popupWindow, animated: false, completion: nil)
    }
    
    func dismissPopup() {
        navigationController.dismiss(animated: false, completion: nil)
    }

    func userDetailsDidSubmit() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    override func start() {

    }
}
