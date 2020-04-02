//
//  User.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct User: Codable {
 	let id: String
  var firstName: String
  var lastName: String?
  var description: String?
  var gender: Gender?
  var dateOfBirth: Date?
  let email: String
  var location: Location?
  var work: String?
  var avatar: String?
  var fullName: String {
    lastName
      .map { "\(firstName) \($0)" }
      .getOrElse(result: firstName)
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
