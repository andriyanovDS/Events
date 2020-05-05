//
//  EventRepository.swift
//  Events
//
//  Created by Dmitry on 01.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Promises
import FirebaseFirestore
import Foundation

protocol EventRepository {
  func user(by: String) -> Promise<User?>
  func userEventState(by: String, userId: String) -> Promise<UserEventState?>
  func updateUserEventStateValue(
    _ value: [String: Bool],
    eventId: String,
    userId: String,
    getStateFallback: @escaping () -> UserEventState
  ) -> Promise<Void>
}

class EventRepositoryFirestore: EventRepository {
  private lazy var db = Firestore.firestore()
  
  func user(by id: String) -> Promise<User?> {
    db
      .collection("user_details")
      .document(id)
      .getDocument()
  }
  
  func userEventState(by id: String, userId: String) -> Promise<UserEventState?> {
    db
      .collection("event-list")
      .document(id)
      .collection("users")
      .document(userId)
      .getDocument()
  }
  
  func updateUserEventStateValue(
    _ value: [String: Bool],
    eventId: String,
    userId: String,
    getStateFallback: @escaping () -> UserEventState
  ) -> Promise<Void> {
    let eventListReference = db
      .collection("event-list")
      .document(eventId)
      .collection("users")
      .document(userId)
    let userDetailsReference = db
      .collection("user_details")
      .document(userId)
      .collection("events")
      .document(eventId)
    return all(on: .global(), [
      updateValue(value, reference: eventListReference, getStateFallback: getStateFallback),
      updateValue(value, reference: userDetailsReference, getStateFallback: getStateFallback)
    ]).then { _ in () }
  }
  
  private func updateValue(
    _ value: [String: Bool],
    reference: DocumentReference,
    getStateFallback: @escaping () -> UserEventState
  ) -> Promise<Void> {
    Promise { resolve, reject in
      self.db.runTransaction({ (transaction, errorPointer) in
        do {
          let document = try transaction.getDocument(reference)
          if !document.exists {
            let event = getStateFallback()
            try reference.setData(from: event)
            return nil
          }
          transaction.updateData(value, forDocument: reference)
        } catch let fetchError as NSError {
          errorPointer?.pointee = fetchError
          return nil
        }
        return nil
      }, completion: { _, error in
        if let error = error {
          reject(error)
          return
        }
        resolve(())
      })
    }
  }
}
