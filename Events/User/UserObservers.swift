//
//  User.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import Promises
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

private let changeUserS = PublishSubject<User>()

func getUser(by id: String, db: Firestore) -> Promise<User> {
	let ref = db
		.collection("user_details")
		.document(id)
	return Promise(on: .global(qos: .userInitiated)) { resolve, reject in
		ref.getDocument(completion: { snapshot, error in
			if let error = error {
				print(error.localizedDescription)
				reject(GetFirestoreDocumentError.failToGetSnapshot)
				return
			}
			guard let snapshot = snapshot else {
				print("Empty user events snapshot")
				reject(GetFirestoreDocumentError.emptySnapshot)
				return
			}
			do {
				let user = try snapshot.data(as: User.self)
				resolve(user!)
			} catch let error {
				print("Failed to decode documents with error \(error)")
				reject(error)
			}
		})
	}
}

let userObserver = Observable<User?>
  .create({ observer in
    var db = Firestore.firestore()
    let userAuthChange = Auth.auth().addStateDidChangeListener { (_, fbUserOptional) in
      guard let fbUser = fbUserOptional else {
        observer.on(.next(nil))
        return
      }
			
			getUser(by: fbUser.uid, db: db)
				.then { user in
					observer.on(.next(user))
				}
				.catch { error in
					print(error)
					let user = User(id: fbUser.uid, email: fbUser.email ?? "")
					observer.on(.next(user))
				}
    }
    return Disposables.create {
      Auth.auth().removeStateDidChangeListener(userAuthChange)
    }
  })
  .share(replay: 1, scope: .forever)

let currentUserObserver: Observable<User> = Observable.merge(
  userObserver
    .filter({ user in user != nil })
    .map({ v in v! }),
  changeUserS
  )
  .share(replay: 1, scope: .forever)

func updateUser(_ user: User) {
  changeUserS.onNext(user)
}

func isStorageUrl(_ url: URL) -> Bool {
  return url.absoluteString.range(
    of: "^https:\\/\\/firebasestorage",
    options: .regularExpression,
    range: nil,
    locale: nil
    ) != nil
}

enum GetFirestoreDocumentError: Error {
	case failToGetSnapshot, emptySnapshot, failToDecode
}
