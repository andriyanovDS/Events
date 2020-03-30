//
//  CreatedEventsViewModel.swift
//  Events
//
//  Created by Dmitry on 29.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import RxCocoa
import Promises
import FirebaseAuth
import FirebaseFirestore

class CreatedEventsViewModel: Stepper {
	weak var delegate: CreatedEventsViewModelDelegate? {
		didSet { loadEvents() }
	}
	var isListLoadedAndEmpty: Bool = false
	let steps = PublishRelay<Step>()
	private var _events: [Event] = []
	private var _filteredEvents: [Event] = []
	private lazy var db = Firestore.firestore()
	
	var events: [Event] { _filteredEvents }
	
	@objc func closeScreen() {
		steps.accept(EventStep.createdEventsDidComplete)
	}
	
	func confirmEventDelete(at index: Int, completionHandler: @escaping (Bool) -> Void) {
		let submitAction = UIAlertAction(
			title: NSLocalizedString("Delete", comment: "Delete event"),
			style: .default,
			handler: {[weak self] _ in
				self?.removeEvent(at: index)
				completionHandler(true)
			}
		)
		let cancelAction = UIAlertAction(
			title: NSLocalizedString("Cancel", comment: "Cancel alert"),
			style: .destructive,
			handler: { _ in completionHandler(false) }
		)
		steps.accept(EventStep.alert(
			title: NSLocalizedString("Warning", comment: "Alert title: waring"),
			message: NSLocalizedString(
				"Are you sure that you want to delete event?",
				comment: "Delete event confirmation"
			),
			actions: [cancelAction, submitAction]
		))
	}
	
	func filterEvents(whereEventName input: String) {
		if input.isEmpty {
			let isArrayChanged = _events != _filteredEvents
			_filteredEvents = _events
			if isArrayChanged { delegate?.listDidUpdate() }
			return
		}
		let newArray = _events.filter { $0.name.contains(input) }
		let isArrayChanged = newArray != _filteredEvents
		_filteredEvents = newArray
		if isArrayChanged { delegate?.listDidUpdate() }
	}
	
	private func removeEvent(at index: Int) {
		let event = _filteredEvents[index]
		guard let removeIndex = _events.firstIndex(of: event) else {
			return
		}
		_events.remove(at: removeIndex)
		_filteredEvents.remove(at: index)
		
		let ref = db.collection("event-list").document(event.id)
		ref.updateData(["isRemoved": true])
	}
	
	private func loadCreatedEventIds(uid: String) -> Promise<[String]> {
		let ref = db
			.collection("user_details")
			.document(uid)
			.collection("events")
			.whereField("isAuthor", isEqualTo: true)
		
		return Promise(on: .global(qos: .background)) { resolve, _ in
			ref.getDocuments(completion: { snapshots, error in
				if let error = error {
					print("Failed to load events", error)
					resolve([])
					return
				}
				guard let documents = snapshots?.documents else {
					resolve([])
					return
				}
				do {
					let userEvents = try documents.compactMap {
						try $0.data(as: UserEvent.self)
					}
					resolve(userEvents.map(\.eventId))
				} catch let error {
					print(error)
					resolve([])
				}
			})
		}
	}
	
	private func loadCreatedEvents(by ids: [String]) -> Promise<[Event]> {
		let ref = db
			.collection("event-list")
			.whereField("id", in: ids)
			.whereField("isRemoved", isEqualTo: false)
		
		return Promise(on: .global(qos: .background)) { resolve, _ in
			ref.getDocuments(completion: { snapshots, error in
				if let error = error {
					print("Failed to load events", error)
					resolve([])
					return
				}
				guard let documents = snapshots?.documents else {
					resolve([])
					return
				}
				do {
					let events = try documents.compactMap {
						try $0.data(as: Event.self)
					}
					resolve(events)
				} catch let error {
					print(error)
					resolve([])
				}
			})
		}
	}
	
	private func loadEvents() {
		guard let uid = Auth.auth().currentUser?.uid else { return}
		Promise<Void>(on: .global(qos: .background)) {[weak self] in
			guard let self = self else { return }
			let ids = try await(self.loadCreatedEventIds(uid: uid))
			guard !ids.isEmpty else {
				self.isListLoadedAndEmpty = true
				return
			}
			let events = try await(self.loadCreatedEvents(by: ids))
			self.isListLoadedAndEmpty = events.isEmpty
			self._events = events
			self._filteredEvents = events
			DispatchQueue.main.async {
				self.delegate?.listDidUpdate()
			}
		}
		.catch { print($0.localizedDescription) }
	}
}

protocol CreatedEventsViewModelDelegate: class {
	func listDidUpdate()
}
