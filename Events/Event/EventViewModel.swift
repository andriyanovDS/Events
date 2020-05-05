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

class EventViewModel: Stepper, EventViewConfiguratorDataSource {
  let steps = PublishRelay<Step>()
	lazy private var uid: String = {
		Auth.auth().currentUser!.uid
	}()
  weak var delegate: EventViewModelDelegate?
  let event: Event
	private(set) var author: User?
	private(set) var userEvent: UserEventState?
  private var isFollowStateUpdateInProgress: Bool = false
  private var isJoinStateUpdateInProgress: Bool = false
  private let db: EventRepository

  init(event: Event, db: EventRepository) {
    self.event = event
    self.db = db
  }

  func onClose() {
		guard let userEvent = userEvent else { return }
		steps.accept(EventStep.eventDidComplete(userEvent: userEvent))
  }
  
  func loadUserEvent() {
		db
      .userEventState(by: event.id, userId: uid)
      .then {[weak self] (userEvent: UserEventState?) in
        guard let self = self else { return }
        self.userEvent = userEvent ?? UserEventState(
          eventId: self.event.id,
          userId: self.uid,
          isFollow: false,
          isJoin: false,
          isAuthor: true
        )
      }
      .always {[weak self] in
        guard let self = self else { return }
        self.delegate?.viewModelDidLoadUserEventState(self)
      }
      .catch {[weak self] error in
        guard let self = self else { return }
        print(error.localizedDescription)
        self.userEvent = UserEventState(
          eventId: self.event.id,
          userId: self.uid,
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
    db.updateUserEventStateValue(
      ["isFollow": !currentValue],
      eventId: event.id,
      userId: uid,
      getStateFallback: {[unowned self] in
        UserEventState(
          eventId: self.event.id,
          userId: self.uid,
          isFollow: !currentValue,
          isJoin: false,
          isAuthor: self.uid == self.event.id
        )
      }
     )
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
    db.updateUserEventStateValue(
      ["isJoin": !currentValue],
      eventId: event.id,
      userId: uid,
      getStateFallback: {[unowned self] in
        UserEventState(
          eventId: self.event.id,
          userId: self.uid,
          isFollow: false,
          isJoin: !currentValue,
          isAuthor: self.uid == self.event.id
        )
      }
    )
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
  
  func loadAuthor() {
    db.user(by: event.author)
      .then {[weak self] author in
        guard let self = self, let author = author else {
          return
        }
        self.author = author
        self.delegate?.viewModelDidLoadAuthor(self)
      }
  }
}

protocol EventViewModelDelegate: class {
  func viewModelDidLoadUserEventState(_: EventViewModel)
  func viewModelDidLoadAuthor(_: EventViewModel)
}
