//
//  ImagePickerViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Photos
import RxFlow
import RxCocoa
import RxSwift

class ImagePickerViewModel: Stepper {
  let steps = PublishRelay<Step>()
  private let onResult: ([UIImage]) -> Void

  var targetSize: CGSize! {
    didSet {
      requestLibraryUsagePermission(
        onOpenLibrary: handleLibrary,
        openLibraryAccessModal: {
          self.steps.accept(EventStep.permissionModal(withType: .library))
        }
      )
    }
  }
  private var images: [UIImage] = []
  private var selectedImageIndices: [Int] = []
  weak var delegate: ImagePickerViewModelDelegate?

  init(onResult: @escaping (([UIImage]) -> Void)) {
    self.onResult = onResult
  }

  func onSelectImageSource(source: ImageSource) {
    switch source {
    case .camera:
      openCamera()
    case .library:
      openLibrary()
    }
  }

  func onSelectImage(_ image: UIImage) -> [Int] {
    guard let imageIndex = images.firstIndex(of: image) else {
      return selectedImageIndices
    }
    if let selectedImageIndex = selectedImageIndices.firstIndex(of: imageIndex) {
      selectedImageIndices.remove(at: selectedImageIndex)
    } else {
      selectedImageIndices.append(imageIndex)
    }
    return selectedImageIndices
  }

  func onConfirmSendImages() {
    delegate?.performCloseAnimation {
      self.onResult(self.selectedImageIndices.map { self.images[$0] })
      self.steps.accept(EventStep.imagePickerDidComplete)
    }
  }

  private func handleCamera() {

  }

  func closeImagePicker(with result: [UIImage]) {
    self.onResult(result)
    self.steps.accept(EventStep.imagePickerDidComplete)
  }

  func openImagesPreview(images: [UIImage], startAt index: Int) {
    steps.accept(EventStep.imagesPreview(
      images: images,
      startAt: index,
      selectedImageIndices: selectedImageIndices,
      onResult: { selectedImageIndices in
        self.selectedImageIndices = selectedImageIndices
        self.delegate?.updateImagePreviews(selectedImageIndices: selectedImageIndices)
      }
    ))
  }

  private func handleLibrary() {
    let fetchOptions = PHFetchOptions()
    let images = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    images.enumerateObjects({ asset, _, _ in
      let options = PHImageRequestOptions()
      options.version = .original
      options.isSynchronous = true
      PHImageManager.default().requestImage(
        for: asset,
        targetSize: self.targetSize,
        contentMode: .aspectFit,
        options: options
        ) { image, _ in
        guard let image = image else {
          return
        }
          self.images.append(image)
          self.delegate?.setupGalleryImage(image: image)
      }
    })
  }

  private func openCamera() {
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      return
    }
    let controller = UIImagePickerController()
    controller.delegate = delegate
    controller.sourceType = .camera
    self.delegate?.present(controller, animated: true, completion: nil)
  }

  private func openLibrary() {
    if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      return
    }
    let controller = UIImagePickerController()
    controller.delegate = delegate
    controller.sourceType = .photoLibrary
    self.delegate?.present(controller, animated: true, completion: nil)
  }
}

func requestCameraUsagePermission(
  onOpenCamera: @escaping () -> Void,
  openCameraAccessModal: @escaping () -> Void
  ) {
  let status = AVCaptureDevice.authorizationStatus(for: .video)
  switch status {
  case .authorized:
    onOpenCamera()
    return
  case .notDetermined:
    AVCaptureDevice.requestAccess(for: .video, completionHandler: {isAuthorized in
      if !isAuthorized {
        return
      }
      onOpenCamera()
    })
  case .denied:
    openCameraAccessModal()
  default: return
  }
}

func requestLibraryUsagePermission(
  onOpenLibrary: @escaping () -> Void,
  openLibraryAccessModal: @escaping () -> Void
  ) {
  let status = PHPhotoLibrary.authorizationStatus()
  switch status {
  case .authorized:
    onOpenLibrary()
    return
  case .notDetermined:
    PHPhotoLibrary.requestAuthorization({ authStatus in
      if authStatus != .authorized {
        return
      }
      onOpenLibrary()
    })
  case .denied:
    openLibraryAccessModal()
  default: return
  }
}

enum ImageSource: CaseIterable {
  case camera, library

  func localizedString() -> String {
    switch self {
    case .camera: return "Камера"
    case .library: return "Галерея"
    }
  }
}

protocol ImagePickerViewModelDelegate: UIImagePickerControllerDelegate,
  UIViewController,
  UINavigationControllerDelegate {
  func setupGalleryImage(image: UIImage)
  func updateImagePreviews(selectedImageIndices: [Int])
  func performCloseAnimation(onComplete: @escaping () -> Void)
}
