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
import RxCocoa
import RxFlow
import FirebaseAuth

class ProfileScreenViewModel: Stepper {
  let steps = PublishRelay<Step>()

  var user: User?
  var userDisposable: Disposable?
  weak var delegate: ProfileScreenViewModelDelegate?
  
  func attemptToOpenUserDetails() {
    userDisposable = currentUserObserver
      .subscribe(onNext: {[weak self] user in
        self?.user = user
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
    steps.accept(EventStep.userDetails(user: user))
  }
  
  func onCreateEvent() {
    steps.accept(EventStep.createEvent)
  }
  
  func logout() {
    do {
      try Auth.auth().signOut()
      steps.accept(EventStep.login)
    } catch {
      return
    }
    
  }
}

protocol ProfileScreenViewModelDelegate: class {
  func onUserDidChange(user: User)
}
