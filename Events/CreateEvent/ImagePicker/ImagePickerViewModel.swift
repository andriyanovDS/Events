//
//  ImagePickerViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

class ImagePickerViewModel {
  let targetSize: CGSize
  let setupGalleryImage: (UIImage) -> Void
  var selectedImages: [UIImage] = []

  init(
    setupGalleryImage: @escaping (UIImage) -> Void,
    targetSize: CGSize
    ) {
    self.targetSize = targetSize
    self.setupGalleryImage = setupGalleryImage
    requestLibraryUsagePermission(onOpenLibrary: self.handleLibrary)
  }

  func onSelectImageSource(source: ImageSource) {

  }

  func onSelectImage(_ image: UIImage) -> Int {
    if selectedImages.contains(image) {
      selectedImages.removeAll(where: { v in
        v == image
      })
    } else {
      selectedImages.append(image)
    }
    return selectedImages.count
  }

  private func handleCamera() {

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
        self.setupGalleryImage(image)
      }
    })
  }
}

func requestCameraUsagePermission(onOpenCamera: @escaping () -> Void) {
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
  default: return
  }
}

func requestLibraryUsagePermission(onOpenLibrary: @escaping () -> Void) {
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
