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
  
  func eventList() -> Promise<[Event]> {
    return db
      .collection("event-list")
      .whereField("isRemoved", isEqualTo: false)
      .getDocuments()
  }
}

protocol RootScreenRepository {
  func eventList() -> Promise<[Event]>
}
