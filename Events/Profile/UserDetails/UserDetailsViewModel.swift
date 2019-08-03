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
import FirebaseDatabase
import FirebaseStorage

class UserDetailsViewModel {

    weak var coordinator: UserDetailsScreenCoordinator?
    let delegate: UserDetailsViewModelDelegate
    lazy var storage = Storage.storage()

    init(delegate: UserDetailsViewModelDelegate) {
        self.delegate = delegate
    }

    func closeScreen() {
        coordinator?.userDetailsDidSubmit()
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
            case .success(_):
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

    private func requestCameraUsagePermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            openCamera()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {isAuthorized in
                if !isAuthorized {
                    return
                }
                self.openCamera()
            })
        case .denied:
            coordinator?.openPermissionPopup(title: "Разрешите доступ к камере в настройках", buttonText: "Понятно")
        default: return
        }
    }

    private func requestLibraryUsagePermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            openLibrary()
            return
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ authStatus in
                if authStatus != .authorized {
                    return
                }
                self.openLibrary()

            })
        default: return
        }
    }

    func showSelectImageActionSheet() {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheetController.addAction(.init(
            title: "Камера",
            style: .default,
            handler: {[weak self] _ in
                self?.requestCameraUsagePermission()
            }
            ))
        actionSheetController.addAction(.init(
            title: "Галерея",
            style: .default,
            handler: {[weak self] _ in
                self?.requestLibraryUsagePermission()
            }
            ))
        actionSheetController.addAction(.init(
            title: "Закрыть",
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
    func openPermissionPopup(title: String, buttonText: String)
}
