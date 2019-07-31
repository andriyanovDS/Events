//
//  ProfileScreenViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import FirebaseAuth

class ProfileScreenViewModel {

    var user: User?
    var userDisposable: Disposable?
    var coordinator: ProfileScreenCoordinator?
    weak var delegate: ProfileScreenViewModelDelegate?

    func attemptToOpenUserDetails() {
        userDisposable = userObserver
            .filter({ user in user != nil })
            .take(1)
            .subscribe(onNext: {[weak self] optionUser in
                self?.user = optionUser
                guard let user = optionUser else {
                    return
                }
                self?.delegate?.onUserDidChange(user: user)
                if user.firstName.isEmpty {
                    self?.openUserDetails()
                }
            })
    }

    deinit {
        if userDisposable != nil {
            userDisposable = nil
        }
    }

    func openUserDetails() {
        guard let user = self.user else {
            return
        }
        coordinator?.openUserDetails(user: user)
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            coordinator?.openLoginScreen()
        } catch {
            return
        }

    }
}

protocol ProfileScreenViewModelDelegate: class {
    func onUserDidChange(user: User)
}
