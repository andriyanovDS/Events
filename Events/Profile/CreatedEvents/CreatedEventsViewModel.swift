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
	private var searchQuery: String = ""
	private var _events: [Event] = []
	private var _filteredEvents: [Event] = []
	private lazy var db = Firestore.firestore()
	private var lastRemovedEvent: RemovedEvent?
	private var eventsListener: ListenerRegistration?
	
	var events: [Event] { _filteredEvents }
	
	private struct RemovedEvent {
		let event: Event
		let position: Int
	}
	
	deinit {
		eventsListener?.remove()
	}
	
	@objc func closeScreen() {
		steps.accept(EventStep.createdEventsDidComplete)
	}
	
	func onEditEvent(_ event: Event) {
		steps.accept(EventStep.editEvent(event: event))
	}
	
	func confirmEventDelete(at index: Int, completionHandler: @escaping (Bool) -> Void) {
		let submitAction = UIAlertAction(
			title: NSLocalizedString("Delete", comment: "Delete event"),
			style: .destructive,
			handler: {[weak self] _ in
				self?.removeEvent(at: index)
				completionHandler(true)
			}
		)
		let cancelAction = UIAlertAction(
			title: NSLocalizedString("Cancel", comment: "Cancel alert"),
			style: .default,
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
		defer { searchQuery = input }
		
		if input.isEmpty {
			let isArrayChanged = _events != _filteredEvents
			_filteredEvents = _events
			if isArrayChanged { delegate?.listDidUpdate() }
			return
		}
		let eventsWithSuitableName = _events.filter { $0.name.contains(input) }
		let isArrayChanged = eventsWithSuitableName != _filteredEvents
		_filteredEvents = eventsWithSuitableName
		if isArrayChanged { delegate?.listDidUpdate() }
	}
	
	func undoEventDeletion() {
		guard let removedEvent = lastRemovedEvent else { return }
		let ref = db
			.collection("event-list")
			.document(removedEvent.event.id)
		ref.updateData(["isRemoved": false])
		
		_events.insert(removedEvent.event, at: removedEvent.position)
		_filteredEvents = searchQuery.isEmpty
			? _events
			: _events.filter { $0.name.contains(searchQuery) }
		delegate?.listDidUpdate()
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
		lastRemovedEvent = RemovedEvent(event: event, position: removeIndex)
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
	
	private func subscribeCreatedEvents(
		by ids: [String],
		onReceive: @escaping ([Event]) -> Void
	) {
		let ref = db
			.collection("event-list")
			.whereField("id", in: ids)
			.whereField("isRemoved", isEqualTo: false)

		eventsListener = ref.addSnapshotListener(
			includeMetadataChanges: false,
			listener: { snapshots, error in
				if let error = error {
					print("Failed to load events", error)
					onReceive([])
					return
				}
				guard let documents = snapshots?.documents else {
					onReceive([])
					return
				}
				do {
					let events = try documents.compactMap {
						try $0.data(as: Event.self)
					}
					onReceive(events)
				} catch let error {
					print(error)
					onReceive([])
				}
			}
		)
	}
	
	private func handleReceivedEvents(_ events: [Event]) {
		isListLoadedAndEmpty = events.isEmpty
		_events = events
		filterEvents(whereEventName: searchQuery)
		DispatchQueue.main.async {
			self.delegate?.didFinishLoading()
			self.delegate?.listDidUpdate()
		}
	}
	
	private func loadEvents() {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		loadCreatedEventIds(uid: uid)
			.then(on: .global()) {[weak self] ids in
				guard let self = self else { return }
				guard !ids.isEmpty else {
					self.isListLoadedAndEmpty = true
					return
				}
				self.subscribeCreatedEvents(by: ids, onReceive: {[weak self] events in
					self?.handleReceivedEvents(events)
				})
			}
			.catch { print($0.localizedDescription) }
	}
}

protocol CreatedEventsViewModelDelegate: class {
	func didFinishLoading()
	func listDidUpdate()
}
