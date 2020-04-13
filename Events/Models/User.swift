//
//  User.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Promises

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
	
	static func load(by id: String, from db: Firestore) -> Promise<Self> {
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
