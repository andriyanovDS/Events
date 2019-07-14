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

struct User {
    let firstName: String
    let lastName: String?
    let description: String?
    let gender: Gender?
    let dateOfBirth: Date?
    let email: String
    let location: Location?
    let work: String?
    let photo: URL?
}

enum Gender: String {
    case male = "Male", female = "Female", other = "Other"
}

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
                    let firstName = value?["firstName"] as? String ?? ""
                    let lastName = value?["lastName"] as? String
                    let description = value?["description"] as? String
                    let dateOfBirth = value?["dateOfBirth"] as? String
                    let gender = value?["gender"] as? Gender
                    let work = value?["work"] as? String
                    let photo = value?["photo"] as? URL
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

                    let date = dateOfBirth.foldL(
                        none: { nil },
                        some: { dateString in
                            return dateFormatter.date(from: dateString)
                        }
                    )

                    let user = User(
                        firstName: firstName,
                        lastName: lastName,
                        description: description,
                        gender: gender,
                        dateOfBirth: date,
                        email: fbUser.email ?? "",
                        location: nil,
                        work: work,
                        photo: photo
                    )
                    observer.on(.next(user))
                })
        }
        return Disposables.create {
            Auth.auth().removeStateDidChangeListener(userAuthChange)
        }
    })
    .share(replay: 1, scope: .forever)
