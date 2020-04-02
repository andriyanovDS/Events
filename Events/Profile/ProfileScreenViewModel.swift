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
  weak var delegate: ProfileScreenViewModelDelegate?
	private let disposeBag = DisposeBag()
	
	func onLoad() {
		currentUserObserver
		.subscribe(onNext: {[weak self] user in
			self?.onUserDidChange(user)
		})
		.disposed(by: disposeBag)
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
	
	func openCreatedEvents() {
		steps.accept(EventStep.createdEvents)
	}
  
  func logout() {
    do {
      try Auth.auth().signOut()
      steps.accept(EventStep.login)
		} catch let error {
			print(error)
      return
    }
  }
	
	private func onUserDidChange(_ user: User) {
		let isAvatarImageChanged = user.avatar != self.user?.avatar
		self.user = user
		self.delegate?.onUserDidChange(
			user: user,
			isAvatarImageChanged: isAvatarImageChanged
		)
		if user.firstName.isEmpty {
			self.openUserDetails()
		}
	}
}

protocol ProfileScreenViewModelDelegate: class {
	func onUserDidChange(user: User, isAvatarImageChanged: Bool)
}
