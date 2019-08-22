//
//  User.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

let fbDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

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
