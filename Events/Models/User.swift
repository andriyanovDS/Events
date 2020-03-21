//
//  User.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

let fbDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

struct User: Codable {
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
  var fullName: String {
    lastName
      .map { "\(firstName) \($0)" }
      .getOrElse(result: firstName)
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

extension User {
  init(id: String, email: String) {
    self.id = id
    self.firstName = "Anonymous user"
    self.email = email
    self.lastName = nil
    self.description = nil
    self.gender = nil
    self.dateOfBirth = nil
    self.location = nil
    self.work = nil
    self.avatar = nil
  }
}

enum Gender: String, Codable {
  case male = "Male", female = "Female", other = "Other"

  func translateValue() -> String {
    switch self {
    case .male: return "Мужской"
    case .female: return "Женский"
    case .other: return "Другое"
    }
  }
}
