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
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Photos.PHAsset
import Promises

class CreateEventViewModel: Stepper {
  let steps = PublishRelay<Step>()
  var geocode: Geocode?
  var dates: [Date] = []
  var duration: EventDurationRange?
  var category: CategoryId?
  var descriptions: [DescriptionWithAssets] = []
  lazy var storage = Storage.storage()

  func closeScreen() {
    steps.accept(EventStep.createEventDidComplete)
  }

  func locationDidSelected(geocode: Geocode) {
    self.geocode = geocode
    openDateScreen()
  }

  func onClose() {
    steps.accept(EventStep.createEventDidComplete)
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

  private func upload(asset: PHAsset) -> Promise<String> {
    return Promise { resolve, reject in
      print("upload image")
      asset.requestContentEditingInput(with: nil, completionHandler: { (input, info) in
        guard let url = input?.fullSizeImageURL else {
          reject(UploadAssetError())
          return
        }
        print("upload url", url)
        let reference = self.storage.reference()
        let eventImageRef = reference.child("event/images")
        eventImageRef.putFile(from: url, metadata: nil, completion: { _, error in
          if let uploadError = error {
            reject(UploadAssetError())
            return
          }
          eventImageRef.downloadURL(completion: { url, error in
            if let error = error {
              reject(UploadAssetError())
              return
            }
            resolve(url!.absoluteString)
          })
        })
      })
    }
  }

  private func descriptionWithImageUrls(
    from description: DescriptionWithAssets
  ) -> Promise<DescriptionWithImageUrls> {
    print("descriptionWithImageUrls", description.assets.count)
    let imageUrls = all(description.assets.map { upload(asset: $0) })
    return imageUrls
      .then { imageUrls -> DescriptionWithImageUrls in
        print("imageUrls", imageUrls.count)
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
    guard let geocode = self.geocode else { return }
    guard let duration = self.duration else { return }
    guard let categoryId = self.category else { return }

    print("createEvent start", self.descriptions.count)

    Promise<Void>(on: .global()) {
      let descriptionsPromise = all(self.descriptions.map { self.descriptionWithImageUrls(from: $0) })
      let descriptions = try await(descriptionsPromise)
      let event = Event(
        name: "First created event",
        author: user.uid,
        location: geocode.geometry.location,
        dates: self.dates,
        duration: duration,
        createDate: Date(),
        categories: [categoryId],
        description: descriptions
      )
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      let eventJson = try encoder.encode(event)
      let ref = Database.database().reference()
      ref
        .child("event")
        .child("list")
        .childByAutoId()
        .setValue(eventJson, withCompletionBlock: { error, ref in
          print("Complete")
        })
    }
    .catch { error in
      print("Error", error)
    }
  }
}

struct UploadAssetError: Error {}
