//
//  RootScreenRepository.swift
//  Events
//
//  Created by Dmitry on 01.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Promises
import FirebaseFirestore

class RootScreenRepositoryFirestore: RootScreenRepository {
  private lazy var db = Firestore.firestore()
  
  func authors(with ids: [String]) -> Promise<[User]> {
    guard !ids.isEmpty else { return Promise([]) }
    return db
      .collection("user_details")
      .whereField("id", in: ids)
      .getDocuments()
  }
  
  func eventList() -> Promise<[Event]> {
    return db
      .collection("event-list")
      .whereField("isRemoved", isEqualTo: false)
      .getDocuments()
  }
}

protocol RootScreenRepository {
  func authors(with: [String]) -> Promise<[User]>
  func eventList() -> Promise<[Event]>
}
