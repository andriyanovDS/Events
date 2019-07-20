//
//  ProfileScreenViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import FirebaseAuth

class ProfileScreenViewModel {

    var coordinator: ProfileScreenCoordinator?

    func logout() {
        do {
            try Auth.auth().signOut()
            coordinator?.openLoginScreen()
        } catch {
            return
        }

    }
}

protocol ProfileScreenCoordinator: Coordinator {
    func openLoginScreen()
}
