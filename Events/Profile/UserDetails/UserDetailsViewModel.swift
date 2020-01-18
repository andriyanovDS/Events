//
//  UserDetailsViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 16/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import UIKit
import RxSwift
import RxCocoa
import RxFlow
import FirebaseDatabase
import FirebaseStorage

class UserDetailsViewModel: Stepper {
  let steps = PublishRelay<Step>()

  weak var delegate: UserDetailsViewModelDelegate!
  lazy var storage = Storage.storage()
  
  func closeScreen() {
    steps.accept(EventStep.userDetailsDidComplete)
  }
}

extension UserDetailsViewModel {
  private func updateUserProfile(
    user: User,
    firstName: String,
    avatar: String?,
    userInfo: [String: Any?]
    ) {
    let updatedUser = User(
      id: user.id,
      firstName: firstName,
      lastName: userInfo["lastName"] as? String,
      description: userInfo["description"] as? String,
      gender: userInfo["gender"] as? Gender,
      dateOfBirth: userInfo["dateOfBirth"] as? Date,
      email: user.email,
      location: nil,
      work: userInfo["work"] as? String,
      avatar: avatar
    )
    Events.updateUserProfile(user: updatedUser, onComplete: { [weak self] result in
      switch result {
      case .success:
        self?.delegate.removeActivityIndicator()
        self?.closeScreen()
        return
      case .failure(let error):
        print("Error", error)
        self?.delegate.removeActivityIndicator()
      }
    })
  }
  
  func submitProfile(userInfo: [String: Any?]) {
    let user = delegate.user
    guard let firstName = userInfo["firstName"] as? String else {
      return
    }
    
    delegate.showActivityIndicator(for: nil)
    
    if let avatarUrl = userInfo["avatar"] as? URL {
      if isStorageUrl(avatarUrl) {
        self.updateUserProfile(
          user: user,
          firstName: firstName,
          avatar: avatarUrl.absoluteString,
          userInfo: userInfo
        )
        return
      }
      uploadAvatar(url: avatarUrl, userId: user.id, onComplete: { [weak self] result in
        switch result {
        case .success(let url):
          self?.updateUserProfile(user: user, firstName: firstName, avatar: url, userInfo: userInfo)
        case .failure:
          self?.updateUserProfile(user: user, firstName: firstName, avatar: nil, userInfo: userInfo)
        }
      })
    } else {
      updateUserProfile(user: user, firstName: firstName, avatar: nil, userInfo: userInfo)
    }
  }
}

extension UserDetailsViewModel {
  private func openCamera() {
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      return
    }
    let controller = UIImagePickerController()
    controller.delegate = delegate
    controller.sourceType = .camera
    self.delegate.present(controller, animated: true, completion: nil)
  }
  
  private func openLibrary() {
    if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      return
    }
    let controller = UIImagePickerController()
    controller.delegate = delegate
    controller.sourceType = .photoLibrary
    self.delegate.present(controller, animated: true, completion: nil)
  }
  
  func showSelectImageActionSheet() {
    let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    actionSheetController.addAction(.init(
      title: NSLocalizedString("Camera", comment: "Select image from: Camera"),
      style: .default,
      handler: {_ in
        requestCameraUsagePermission(
          onOpenCamera: self.openCamera,
          openCameraAccessModal: {
            self.steps.accept(EventStep.permissionModal(withType: .camera))
          })
      }
    ))
    actionSheetController.addAction(.init(
      title: NSLocalizedString("Gallery", comment: "Select image from: Gallery"),
      style: .default,
      handler: {_ in
        requestLibraryUsagePermission(
          onOpenLibrary: self.openLibrary,
          openLibraryAccessModal: {
            self.steps.accept(EventStep.permissionModal(withType: .library))
          }
        )
      }
    ))
    actionSheetController.addAction(.init(
      title: NSLocalizedString("Close", comment: "Close select image modal"),
      style: .cancel,
      handler: nil)
    )
    self.delegate.present(actionSheetController, animated: true, completion: nil)
  }
  
  private func uploadAvatar(url: URL, userId: String, onComplete: @escaping (Result<String, Error>) -> Void) {
    let reference = storage.reference()
    let avatarRef = reference.child("users/\(userId)/images")
    avatarRef.putFile(from: url, metadata: nil, completion: { _, error in
      if let uploadError = error {
        onComplete(.failure(uploadError))
        return
      }
      avatarRef.downloadURL(completion: { url, error in
        if let error = error {
          onComplete(.failure(error))
          return
        }
        onComplete(.success(url!.absoluteString))
      })
    })
  }
}

protocol UserDetailsViewModelDelegate: UIViewControllerWithActivityIndicator,
  UIImagePickerControllerDelegate,
  UINavigationControllerDelegate {
  var user: User { get }
}

protocol UserDetailsScreenCoordinator: class {
  func userDetailsDidSubmit()
  func openLibraryAccessModal()
  func openCameraAccessModal(navigationController: UINavigationController)
}
