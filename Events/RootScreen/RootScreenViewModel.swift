//
//  RootScreenViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import RxCocoa
import Promises
import UIKit
import FirebaseFirestore
import AVFoundation

class RootScreenViewModel: Stepper {
  let steps = PublishRelay<Step>()
  weak var delegate: RootScreenViewModelDelegate?
  private(set) var authors: [String: User] = [:]
  private lazy var firestoreDb = Firestore.firestore()
  private(set) var eventList: [Event] = []
  
  func loadEventList() {
    firestoreDb
      .collection("event-list")
      .whereField("isRemoved", isEqualTo: false)
      .getDocuments()
      .then {[weak self] (events: [Event]) in
        guard let self = self else { return }
        self.eventList = events
        let indexPaths = events
          .enumerated()
          .map {(index, _) in IndexPath(item: index, section: 0)}
        self.delegate?.viewModel(self, didAddEventsAt: indexPaths)
        self.loadAuthors(ids: events.map { $0.author })
      }
      .catch { print($0.localizedDescription) }
  }

  func openEvent(at index: Int, sharedImage: UIImage?) {
		let event = eventList[index]
		guard let author = authors[event.author] else { return }
		steps.accept(EventStep.event(
			event: event,
			author: author,
			sharedImage: sharedImage
		))
  }

  private func loadAuthors(ids: [String]) {
    guard !ids.isEmpty else { return }
    firestoreDb
      .collection("user_details")
      .whereField("id", in: ids)
      .getDocuments()
      .then {[weak self] (users: [User]) in
        guard let self = self else { return }
        users.forEach { user in self.authors[user.id] = user }
        let indexPaths = self.eventList
          .enumerated()
          .map {(index, _) in IndexPath(item: index, section: 0)}
        self.delegate?.viewModel(self, didUpdateAuthorsAt: indexPaths)
      }
      .catch { print($0.localizedDescription) }
  }
}

protocol RootScreenViewModelDelegate: class {
  func viewModel(_ viewModel: RootScreenViewModel, didAddEventsAt: [IndexPath])
  func viewModel(_ viewModel: RootScreenViewModel, didUpdateAuthorsAt: [IndexPath])
}
