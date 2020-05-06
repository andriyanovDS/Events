//
//  CreatedEventsRepository.swift
//  Events
//
//  Created by Dmitry on 06.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxSwift
import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol CreatedEventsRepository {
  func undoEventDeletion(withId: String)
  func removeEvent(withId: String)
  func makeCreatedEventObservable() -> Observable<[Event]>
}

class CreatedEventsFirestoreRepository: CreatedEventsRepository {
  private lazy var db = Firestore.firestore()
  
  func undoEventDeletion(withId id: String) {
    let ref = db
      .collection("event-list")
      .document(id)
    ref.updateData(["isRemoved": false])
  }
  
  func removeEvent(withId id: String) {
    db
      .collection("event-list")
      .document(id)
      .updateData(["isRemoved": true])
  }
  
  func makeCreatedEventObservable() -> Observable<[Event]> {
    guard let uid = Auth.auth().currentUser?.uid else {
      return Observable.empty()
    }
    let query = db
      .collection("event-list")
      .whereField("author", isEqualTo: uid)
      .whereField("isRemoved", isEqualTo: false)
    return Observable<[Event]>.fromSnapshotListener(query: query)
  }
}
