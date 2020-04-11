//
//  CreateEventViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import RxFlow
import RxCocoa
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseStorage
import Photos.PHAsset
import Promises

class CreateEventViewModel: Stepper {
  let steps = PublishRelay<Step>()
	weak var delegate: CreateEventViewModelDelegate?
	private var name: String?
	private var isPublic: Bool?
  private var geocode: Geocode?
  private var dates: [Date] = []
  private var duration: EventDurationRange?
  private var category: CategoryId?
  private var descriptions: [DescriptionWithAssets] = []
  private lazy var storage = Storage.storage()
	private lazy var descriptionLoadingQueue = DispatchQueue(label: "descriptionLoading")
	private lazy var imageLoadingQueue = DispatchQueue(label: "imageLoading")

  func closeScreen() {
    steps.accept(EventStep.createEventDidComplete)
  }

	func eventStartDataDidSelected(data: StartViewResult) {
		name = data.name
		isPublic = data.isPublic
		openLocationScreen()
  }

  func onClose() {
    steps.accept(EventStep.createEventDidComplete)
  }
	
	func openLocationScreen() {
		steps.accept(CreateEventStep.location(onResult: {[weak self] geocode in
			self?.geocode = geocode
			self?.openDateScreen()
		}))
	}

  func openDateScreen() {
    steps.accept(CreateEventStep.date(onResult: {[weak self] result in
      self?.dates = result.dates
      self?.duration = result.duration
      self?.openCategoryScreen()
    }))
  }

  private func openCategoryScreen() {
    steps.accept(CreateEventStep.category(onResult: {[weak self] categoryId in
      self?.category = categoryId
      self?.openDescriptionScreen()
    }))
  }

  private func openDescriptionScreen() {
    steps.accept(CreateEventStep.description(onResult: {[weak self] descriptions in
      self?.descriptions = descriptions
      self?.createEvent()
    }))
  }
	
	private func eventDidCreated() {
		steps.accept(EventStep.createEventDidComplete)
	}

	private func upload(fileUrl: URL, userId: String) -> Promise<String> {
		return Promise(on: .global()) { resolve, reject in
			let reference = self.storage.reference()
			let eventImageRef = reference.child("event/\(userId)/images/\(UUID().uuidString.lowercased())")
			eventImageRef.putFile(from: fileUrl, metadata: nil, completion: { _, error in
				if let uploadError = error {
					reject(uploadError)
					return
				}
				eventImageRef.downloadURL(completion: { url, error in
					if let error = error {
						reject(error)
						return
					}
					resolve(url!.absoluteString)
				})
			})
    }
  }
	
	private func setUserEvent(id: String, uid: String, db: Firestore) {
		let userEvent = UserEvent(
			eventId: id,
			userId: uid,
			isFollow: false,
			isJoin: false,
			isAuthor: true
		)
		let refUserDetails = db
			.collection("user_details")
			.document(uid)
			.collection("events")
			.document(id)
		
		let refEvent = db
			.collection("event-list")
			.document(id)
			.collection("users")
			.document(uid)
		
		do {
			try refUserDetails.setData(from: userEvent, completion: { error in
				if let error = error { print(error) }
			})
			try refEvent.setData(from: refEvent, completion: { error in
				if let error = error { print(error) }
			})
		} catch let error {
			print("Failed to set user event with error \(error.localizedDescription)")
		}
	}

	private func descriptionWithImageUrls(
		from description: DescriptionWithAssets,
		userId: String
	) -> Promise<DescriptionWithImageUrls> {
		let imageUrls = all(description.assets.map { upload(fileUrl: $0.localUrl, userId: userId) })
		return imageUrls
			.then { imageUrls -> DescriptionWithImageUrls in
				return DescriptionWithImageUrls(
					isMain: description.isMain,
					id: description.id,
					title: description.title,
					imageUrls: imageUrls,
					text: description.text
				)}
	}

  private func createEvent() {
    guard let user = Auth.auth().currentUser else { return }
		guard let name = name else { return }
    guard let geocode = geocode else { return }
    guard let duration = duration else { return }
    guard let categoryId = category else { return }

		delegate?.showProgress()
    Promise<Void>(on: .global()) {[weak self] in
			guard let self = self else { return }
			let descriptionsPromise = all(
				self.descriptions.map {
					self.descriptionWithImageUrls(from: $0, userId: user.uid)
				}
			)
      let descriptions = try await(descriptionsPromise)
			let db = Firestore.firestore()
      let document = db.collection("event-list").document()

      let event = Event(
        id: document.documentID,
        name: name,
        author: user.uid,
        isPublic: self.isPublic!,
        location: EventLocation(
          lat: geocode.geometry.location.lat,
          lng: geocode.geometry.location.lng,
          fullName: geocode.fullLocationName()
        ),
        dates: self.dates,
				isRemoved: false,
        duration: duration,
        createDate: Date(),
        categories: [categoryId],
        description: descriptions
      )

      try document.setData(from: event, completion: { error in
        if let error = error {
          print("Error", error)
          return
        }
				self.setUserEvent(id: document.documentID, uid: user.uid, db: db)
        self.eventDidCreated()
      })
    }
		.always(on: .main, {
			self.delegate?.hideProgress()
		})
    .catch { error in
      print("Error", error)
    }
  }
}

struct UploadAssetError: Error {}

protocol CreateEventViewModelDelegate: class {
	func showProgress()
	func hideProgress()
}
