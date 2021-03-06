//
//  EventsViewModel.swift
//  Events
//
//  Created by Dmitry on 26.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Promises
import RxFlow
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

class EventsViewModel: Stepper {
	let steps = PublishRelay<Step>()
	var events: [Event] { _events }
	var isLoadedListEmpty: Bool = false
	let db = Firestore.firestore()
	weak var delegate: EventsViewModelDelegate?
	private var _events: [Event] = []
	
	func clearEvents() {
		_events = []
		isLoadedListEmpty = false
	}
	
	func removeEvent(with id: String) {
		guard let index = _events.firstIndex(where: { $0.id == id }) else {
			return
		}
		_events.remove(at: index)
		isLoadedListEmpty = _events.isEmpty
		delegate?.listDidUpdated()
	}
	
	func openEvent(_ event: Event) {
    steps.accept(EventStep.event(
      event: event,
      sharedImage: nil,
      sharedCardInfo: nil
    ))
	}
	
	func loadList() {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		Promise<[Event]>(on: .global()) {[weak self] () -> [Event] in
			guard let self = self else { return [] }
			let eventsIds = try await(self.loadUserEventIds(uid: uid))
			let events = try await(self.loadEvents(ids: eventsIds))
			return events
		}
		.then { events in
			self._events = events.sorted(by: { $0.dates.first! > $1.dates.first! })
			self.isLoadedListEmpty = events.isEmpty
			self.delegate?.listDidUpdated()
		}
	}
	
	private func loadUserEventIds(uid: String) -> Promise<[String]> {
		let ref = db
			.collection("user_details")
			.document(uid)
			.collection("events")
			.whereField("isJoin", isEqualTo: true)
		
		return Promise(on: .global(qos: .background)) { resolve, _ in
			ref
				.whereField("isJoin", isEqualTo: true)
				.getDocuments(completion: { snapshot, error in
					if let error = error {
						print("Failed to load user events with error \(error.localizedDescription)")
						resolve([])
						return
					}
					guard let snapshot = snapshot else {
						print("Empty user events snapshot")
						resolve([])
						return
					}
					do {
						let userEvents = try snapshot.documents.compactMap {
              try $0.data(as: UserEventState.self)
            }
						resolve(userEvents.map(\.eventId))
					} catch let error {
						print("Failed to decode documents with error \(error)")
					}
				})
		}
	}
	
	private func loadEvents(ids: [String]) -> Promise<[Event]> {
		guard ids.count > 0 else { return Promise([]) }
		let db = Firestore.firestore()
		let ref = db
			.collection("event-list")
			.whereField("id", in: ids)
			.whereField("isRemoved", isEqualTo: false)
		return Promise(on: .global(qos: .background)) { resolve, _ in
			ref.getDocuments(completion: { snapshot, error in
				if let error = error {
					print("Failed to load events with error \(error.localizedDescription)")
					resolve([])
					return
				}
				guard let snapshot = snapshot else {
					print("Empty events snapshot")
					resolve([])
					return
				}
				do {
					let events = try snapshot.documents.compactMap {
						try $0.data(as: Event.self)
					}
					resolve(events)
				} catch let error {
					print("Failed to decode documents with error \(error)")
				}
			})
		}
	}
}

extension EventsViewModel: EventsEmptyListCellNodeDelegate {
	func exploreEvents() {
		steps.accept(EventStep.home)
	}
}

protocol EventsViewModelDelegate: class {
	func listDidUpdated()
}
