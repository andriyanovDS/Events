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

        if let dateOfBirth = dateOfBirthToString() {
            details["dateOfBirth"] = dateOfBirth
        }

        return details
            .filter {(_, value) in value != nil }
            .mapValues { $0! }
    }

    private func dateOfBirthToString() -> String? {
        guard let date = dateOfBirth else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fbDateFormat
        return dateFormatter.string(from: date)
    }
}

enum Gender: String {
    case male = "Male", female = "Female", other = "Other"

    func translateValue() -> String {
        switch self {
        case .male: return "Мужской"
        case .female: return "Женский"
        case .other: return "Другое"
        }
    }
}

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
