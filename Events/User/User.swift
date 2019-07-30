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

private let fbDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

struct User {
    let id: String
    let firstName: String
    let lastName: String?
    let description: String?
    let gender: Gender?
    let dateOfBirth: Date?
    let email: String
    let location: Location?
    let work: String?
    let avatar: String?

    func getUserDetails() -> [String: Any] {
        var details: [String: Any?] = [
            "firstName": firstName,
            "lastName": lastName,
            "description": description,
            "gender": gender?.rawValue,
            "work": work,
            "avatar": avatar
        ]

        if let dateOfBirth = self.dateOfBirth {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = fbDateFormat

            details["dateOfBirth"] = dateFormatter.string(from: dateOfBirth)
        }

        return details
            .filter {(_, value) in value != nil }
            .mapValues { $0! }
    }
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
            let result: Result<Void, Error> = .success
            onComplete(result)
        }
}
