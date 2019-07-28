//
//  ProfileCoordinator.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class ProfileScreenCoordinator: MainCoordinator, UserDetailsScreenCoordinator {

    func openUserDetails(user: User) {
        let userDetailsViewController = UserDetailsViewController()
        userDetailsViewController.user = user
        userDetailsViewController.coordinator = self
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

    override func start() {
        let profileScreenViewController = ProfileScreenViewController()
        profileScreenViewController.coordinator = self
        navigationController.pushViewController(profileScreenViewController, animated: false)
    }
}
