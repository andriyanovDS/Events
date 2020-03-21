//
//  User.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

private let changeUserS = PublishSubject<User>()

let userObserver = Observable<User?>
  .create({ observer in
    var db = Firestore.firestore()
    let userAuthChange = Auth.auth().addStateDidChangeListener { (_, fbUserOptional) in
      guard let fbUser = fbUserOptional else {
        observer.on(.next(nil))
        return
      }

      db
      .collection("user_details")
      .document(fbUser.uid)
      .getDocument { (document, error) in
        let result = Result {
          try document.flatMap {
            try $0.data(as: User.self)
          }
        }
        switch result {
        case .success(let user):
          if let user = user {
            observer.on(.next(user))
          } else {
            let user = User(id: fbUser.uid, email: fbUser.email ?? "")
            observer.on(.next(user))
          }
        case .failure(let error):
          let user = User(id: fbUser.uid, email: fbUser.email ?? "")
          observer.on(.next(user))
        }
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

func updateUserProfile(user: User, onComplete: @escaping (Result<Void, Error>) -> Void) {
  do {
    let db = Firestore.firestore()
    let collectionRef = db.collection("user_details")
    try collectionRef
      .document(user.id)
      .setData(from: user, completion: { error in
        if let error = error {
          onComplete(.failure(error))
          return
        }
        changeUserS.onNext(user)
        let result: Result<Void, Error> = .success
        onComplete(result)
      })
  } catch {
    onComplete(.failure(error))
  }
}

func isStorageUrl(_ url: URL) -> Bool {
  return url.absoluteString.range(
    of: "^https:\\/\\/firebasestorage",
    options: .regularExpression,
    range: nil,
    locale: nil
    ) != nil
}
