//
//  CurrentUser.swift
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

class CurrentUser {
	private let db = Firestore.firestore()
	private let disposeBag = DisposeBag()
	private let user$ = ReplaySubject<User?>.create(bufferSize: 1)
	
	var loggedUser$: Observable<User>
	
	var loggedUserPromise: Promise<User> {
		loggedUser$.toPromise(disposeBag: disposeBag)
	}
	
	var userOptionalPromise: Promise<User?> {
		user$.toPromise(disposeBag: disposeBag)
	}
	
	private init() {
		loggedUser$ = user$.compactMap { $0 }
		subscribeCurrentUser()
	}
	
	static let shared = CurrentUser()
	
	private func subscribeCurrentUser() {
		Observable<FirebaseAuth.User?>
			.create { observer in
				let auth = Auth.auth()
				let userAuthChange = auth.addStateDidChangeListener { (_, fbUserOptional) in
					observer.onNext(fbUserOptional)
				}
				return Disposables.create {
					auth.removeStateDidChangeListener(userAuthChange)
				}
			}
		.concatMap {[unowned self] fbUserOption -> Observable<User?> in
			fbUserOption
				.map { fbUser -> Observable<User?> in
					let ref = self.db
						.collection("user_details")
						.document(fbUser.uid)
					return Observable<User>
						.fromSnapshotListener(ref: ref)
						.map { Optional($0) }
				}
				.getOrElse(result: Observable.of(nil))
		}
		.bind(to: user$)
		.disposed(by: disposeBag)
	}
}

enum GetFirestoreDocumentError: Error {
	case failToGetSnapshot, emptySnapshot, failToDecode
}
