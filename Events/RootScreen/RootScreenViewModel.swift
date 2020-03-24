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
  var eventList: [Event] { _eventList }
  private var authors: [String: User] = [:]
  private lazy var firestoreDb = Firestore.firestore()
  private var _eventList: [Event] = [] {
    didSet {
      delegate?.onAppendEventList(
        Array(_eventList.dropFirst(oldValue.count))
      )
    }
  }

  init() {
    loadEventList()
  }

  func author(id: String) -> User? {
    authors[id]
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

  private func loadAuthors(ids: [String]) -> Promise<[User]> {
    Promise(on: .global()) { resolve, reject in
      self.firestoreDb
        .collection("user_details")
        .whereField("id", in: ids)
        .getDocuments(completion: { snapshot, error in
          if let error = error {
            reject(error)
            return
          }
          do {
            guard let documents = snapshot?.documents else {
              print("Empty snapshot for user_details collection")
              return
            }
            let users = try documents.compactMap {
              try $0.data(as: User.self)
            }
            resolve(users)
          } catch {
            reject(error)
          }
        })
      }
  }

  private func loadEventList() {
    firestoreDb
      .collection("event-list")
      .getDocuments(completion: {[weak self] snapshot, error in
        guard let self = self else { return }
        if let error = error {
          // TODO: handle erorr on UI
          print("error", error.localizedDescription)
          return
        }
        guard let documents = snapshot?.documents else {
          print("Empty snapshot for event-list collection")
          return
        }
        Promise<Void>(on: .global()) {
          let list = try documents.compactMap {
             try $0.data(as: Event.self)
           }
          if !list.isEmpty {
            let authors = try await(self.loadAuthors(ids: list.map { $0.author }))
            authors.forEach { user in self.authors[user.id] = user }
          }
          DispatchQueue.main.async {
            self._eventList = list
          }
        }
    })
  }
}

protocol RootScreenViewModelDelegate: class {
  func onAppendEventList(_: [Event])
}
