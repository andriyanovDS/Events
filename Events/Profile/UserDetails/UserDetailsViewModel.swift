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
import RxSwift
import UIKit

class UserDetailsViewModel {

    var disposable: Disposable?
    weak var coordinator: UserDetailsScreenCoordinator?
    weak var delegate: UserDetailsViewModelDelegate!

    init(delegate: UserDetailsViewModelDelegate) {
        self.delegate = delegate
        delegate.showActivityIndicator(for: nil)
        disposable = userObserver
            .take(1)
            .subscribe(onNext: {[weak self] optionalUser in
                self?.disposable = nil
                let user = optionalUser!
                self?.delegate.removeActivityIndicator()
                if user.firstName.isEmpty {
                    self?.delegate.userId = user.id
                    return
                }
                self?.closeScreen()
            })
    }

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
            print("1")
        case .restricted:
            print("1")
        default: return
        }
    }

    private func openLibraryUsagePermission() {
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

    @objc func showSelectImageActionSheet() {
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
                self?.openLibraryUsagePermission()
            }
        ))
        actionSheetController.addAction(.init(
            title: "Закрыть",
            style: .cancel,
            handler: nil)
        )
        self.delegate.present(actionSheetController, animated: true, completion: nil)
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func closeScreen() {
        coordinator?.openProfileScreen()
    }
}

protocol UserDetailsViewModelDelegate: class, UIViewControllerWithActivityIndicator, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var userId: String? { get set }
}

protocol UserDetailsScreenCoordinator: class {
    func openProfileScreen()
}
