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
import FirebaseDatabase

private let changeUserS = PublishSubject<User>()

let userObserver = Observable<User?>
  .create({ observer in
    var reference = Database.database().reference()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let userAuthChange = Auth.auth().addStateDidChangeListener { (_, fbUserOptional) in
      guard let fbUser = fbUserOptional else {
        observer.on(.next(nil))
        return
      }
      reference
        .child("users")
        .child("details")
        .child(fbUser.uid)
        .observeSingleEvent(of: .value, with: { snapshot in
          let value = snapshot.value as? NSDictionary
          let genderValue =  value?["gender"] as? String
          let firstName = value?["firstName"] as? String ?? ""
          let lastName = value?["lastName"] as? String
          let description = value?["description"] as? String
          let dateOfBirth = value?["dateOfBirth"] as? String
          let gender = genderValue.foldL(
            none: { nil },
            some: { v in Gender(rawValue: v)
          })
          let work = value?["work"] as? String
          let avatar = value?["avatar"] as? String
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = fbDateFormat
          
          let date = dateOfBirth.foldL(
            none: { nil },
            some: { dateString in
              return dateFormatter.date(from: dateString)
          }
          )
          
          let user = User(
            id: fbUser.uid,
            firstName: firstName,
            lastName: lastName,
            description: description,
            gender: gender,
            dateOfBirth: date,
            email: fbUser.email ?? "",
            location: nil,
            work: work,
            avatar: avatar
          )
          observer.on(.next(user))
        })
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
  let reference = Database.database().reference()
  
  reference
    .child("users")
    .child("details")
    .child(user.id)
    .setValue(user.getUserDetails()) { error, _  in
      if let error = error {
        onComplete(.failure(error))
        return
      }
      changeUserS.onNext(user)
      let result: Result<Void, Error> = .success
      onComplete(result)
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
