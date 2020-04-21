//
//  EventViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxCocoa
import RxFlow
import Promises
import FirebaseAuth
import FirebaseFirestore

class EventViewModel: Stepper, EventViewConfiguratorDataSource {
  let steps = PublishRelay<Step>()
	lazy private var db = Firestore.firestore()
	lazy private var uid: String = {
		Auth.auth().currentUser!.uid
	}()

  let event: Event
	let author: User
	private(set) var userEvent: UserEvent?
  private var isFollowStateUpdateInProgress: Bool = false
  private var isJoinStateUpdateInProgress: Bool = false

	init(event: Event, author: User) {
    self.event = event
		self.author = author
  }

  @objc func onClose() {
		guard let userEvent = userEvent else { return }
		steps.accept(EventStep.eventDidComplete(userEvent: userEvent))
  }
	
  func loadUserEvent(completion: @escaping () -> Void) {
    let eventId = event.id
    let userId = uid
		db
			.collection("event-list")
			.document(event.id)
			.collection("users")
			.document(uid)
      .getDocument()
      .then {[weak self] (userEvent: UserEvent?) in
        self?.userEvent = userEvent
      }
      .always { completion() }
      .catch {[weak self] error in
        print(error.localizedDescription)
        self?.userEvent = UserEvent(
          eventId: eventId,
          userId: userId,
          isFollow: false,
          isJoin: false,
          isAuthor: true
        )
      }
	}
  
  func toggleFollowEventState(completion: @escaping (Bool) -> Void) {
    guard !isFollowStateUpdateInProgress, let currentValue = userEvent?.isFollow else {
      completion(userEvent?.isFollow ?? false)
      return
    }
    isFollowStateUpdateInProgress = true
    updateUserEvent(value: ["isFollow": !currentValue])
      .then {[weak self] in
        self?.userEvent?.isFollow = !currentValue
        completion(!currentValue)
      }
      .catch { error in
        print(error.localizedDescription)
        completion(currentValue)
      }
      .always {[weak self] in
        self?.isFollowStateUpdateInProgress = false
      }
  }
  
  func toggleJoinEventState(completion: @escaping (Bool) -> Void) {
    guard !isJoinStateUpdateInProgress, let currentValue = userEvent?.isJoin else {
      completion(userEvent?.isJoin ?? false)
      return
    }
    isJoinStateUpdateInProgress = true
    updateUserEvent(value: ["isJoin": !currentValue])
      .then {[weak self] in
        self?.userEvent?.isJoin = !currentValue
        completion(!currentValue)
    }
    .catch {error in
      print(error.localizedDescription)
      completion(currentValue)
    }
    .always {[weak self] in
      self?.isJoinStateUpdateInProgress = false
    }
  }
	
	private func updateUserEvent(
		value: [String: Bool]
	) -> Promise<Void> {
		let eventListReference = db
			.collection("event-list")
			.document(event.id)
			.collection("users")
			.document(uid)
		let userDetailsReference = db
			.collection("user_details")
			.document(uid)
			.collection("events")
			.document(event.id)
		let eventId = event.id
		return Promise<Void>(on: .global(qos: .default)) {
			_ = try await(self.updateUserEventInFirestore(
				value: value,
				eventId: eventId,
				reference: eventListReference
			))
			_ = try await(self.updateUserEventInFirestore(
				value: value,
				eventId: eventId,
				reference: userDetailsReference
			))
		}
	}
	
	private func updateUserEventInFirestore(
		value: [String: Bool],
		eventId: String,
		reference: DocumentReference
	) -> Promise<Any?> {
		return wrap(on: .global(qos: .default)) { handler in
			self.db.runTransaction({[unowned self] (transaction, errorPointer) in
				do {
					let document = try transaction.getDocument(reference)
					if !document.exists {
						let user = UserEvent(
							eventId: eventId,
							userId: self.uid,
							isFollow: false,
							isJoin: true,
							isAuthor: eventId == self.uid
						)
						try reference.setData(from: user)
						return nil
					}
					transaction.updateData(value, forDocument: reference)
				} catch let fetchError as NSError {
					errorPointer?.pointee = fetchError
					return nil
				}
				return nil
			}, completion: handler)
		}
	}
}
