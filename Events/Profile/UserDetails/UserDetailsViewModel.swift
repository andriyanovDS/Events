//
//  UserDetailsViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 16/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import UIKit
import RxSwift
import RxCocoa
import RxFlow
import Promises
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

class UserDetailsViewModel: Stepper {
	var user: User
  let steps = PublishRelay<Step>()
  private lazy var storage = Storage.storage()
	
	init(user: User) {
		self.user = user
	}
  
  func closeScreen() {
    steps.accept(EventStep.userDetailsDidComplete)
  }
	
	func uploadAvatar(url: URL, userId: String) -> Promise<String> {
    let avatarRef = storage
			.reference()
			.child("users/\(userId)/avatarImage/\(md5Hex(string: url.absoluteString))")
		return Promise { resolve, reject in
			avatarRef.putFile(from: url, metadata: nil, completion: { _, error in
				if let uploadError = error {
					reject(uploadError)
					return
				}
				avatarRef.downloadURL(completion: { url, error in
					if let error = error {
						reject(error)
						return
					}
					resolve(url!.absoluteString)
				})
			})
		}
  }
	
	func updateUserProfile() {
		let user = self.user
		let db = Firestore.firestore()
		let collectionRef = db.collection("user_details")
		do {
			try collectionRef
				.document(user.id)
				.setData(from: user, completion: {[weak self] error in
					if let error = error {
						print(error.localizedDescription)
						return
					}
					updateUser(user)
					self?.closeScreen()
				})
		} catch let error {
			print(error.localizedDescription)
		}
  }
	
	func openPermissionModal(withType type: PermissionModalType) {
		steps.accept(EventStep.permissionModal(withType: type))
	}
}
