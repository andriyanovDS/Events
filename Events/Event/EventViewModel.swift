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

class EventViewModel: Stepper, EventNodeDataSource {
  let steps = PublishRelay<Step>()
	lazy private var db = Firestore.firestore()
	lazy private var uid: String = {
		guard let uid = Auth.auth().currentUser?.uid else {
			fatalError("User id must exist")
		}
		return uid
	}()

  let event: Event
	let author: User
	var isCloseAnimationInProgress: Bool = false
	var userFollowEventState: EventViewController.FollowEventState = .inProgress

	init(event: Event, author: User) {
    self.event = event
		self.author = author
  }

  func onClose() {
    steps.accept(EventStep.eventDidComplete)
  }
	
	func userEvent() -> Promise<EventUser> {
		let reference = db
			.collection("event-list")
			.document(event.id)
			.collection("users")
			.document(uid)
		let eventId = event.id
		let userId = uid
		return Promise<EventUser> { resolve, _ in
			let failedEventUser = EventUser(
				eventId: eventId,
				userId: userId,
				isFollow: false,
				isJoin: false
			)
			reference.getDocument(completion: { snapshot, error in
				if let error = error {
					print("Failed to get user event document \(error.localizedDescription)")
					resolve(failedEventUser)
					return
				}
				guard let snapshot = snapshot else {
					resolve(failedEventUser)
					return
				}
				do {
					let data = try snapshot.data(as: EventUser.self)
					resolve(data ?? failedEventUser)
				} catch let decodeError {
					print("Failed to decode event user with error \(decodeError.localizedDescription)")
					resolve(failedEventUser)
				}
			})
		}
	}
	
	func updateUserEvent(
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
		let userId = self.uid
		return wrap(on: .global(qos: .default)) { handler in
			self.db.runTransaction({(transaction, errorPointer) in
				do {
					let document = try transaction.getDocument(reference)
					if !document.exists {
						let user = EventUser(
							eventId: eventId,
							userId: userId,
							isFollow: false,
							isJoin: true
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
