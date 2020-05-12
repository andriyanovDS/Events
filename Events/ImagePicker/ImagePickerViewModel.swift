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
import Promises

class ImagePickerViewModel: NSObject, Stepper, ResultProvider {
  let steps = PublishRelay<Step>()
  let onResult: ResultHandler<[PHAsset]>

  weak var delegate: ImagePickerViewModelDelegate?
  private let previouslySelectedAssets: [PHAsset]

  init(selectedAssets: [PHAsset], onResult: @escaping ResultHandler<[PHAsset]>) {
    self.onResult = onResult
    self.previouslySelectedAssets = selectedAssets
  }

  func onViewReady() {
    requestLibraryUsagePermission(
      onOpenLibrary: handleLibrary,
      openLibraryAccessModal: {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
          self.steps.accept(EventStep.permissionModal(withType: .library))
        })
      }
    )
  }

  func onSelectImageSource(source: ImageSource) {
    steps.accept(EventStep.defaultImagePicker(source: source.type, delegate: self))
  }

  func confirmSelectedAssets(_ assets: [PHAsset]) {
    onResult(assets)
    steps.accept(EventStep.imagePickerDidComplete)
  }

  private func handleCamera() {}

  func openImagesPreview(
    with assets: PHFetchResult<PHAsset>,
    whereSelected selectedIndices: [Int],
    startAt index: Int,
    sharedImage: SharedImage
  ) {
    steps.accept(EventStep.imagesPreview(
      assets: assets,
      sharedImage: sharedImage,
      selectedImageIndices: selectedIndices,
      onImageDidSelected: {[weak self] index in
        guard let self = self else { return }
        self.delegate?.viewModel(self, didSelectImageAt: index)
      }
    ))
  }

  private func handleLibrary() {
    let fetchOptions = PHFetchOptions()
    fetchOptions.includeAssetSourceTypes = .typeUserLibrary
		let sortByDateDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
		fetchOptions.sortDescriptors = [sortByDateDescriptor]
    let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    delegate?.viewModel(
      self,
      didLoadAssets: assets,
      whereSelected: previouslySelectedAssets.map { assets.index(of: $0)}
    )
  }
}

extension ImagePickerViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    steps.accept(EventStep.defaultImagePickerDidComplete)
    if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
      confirmSelectedAssets([asset])
    }
  }
}

func requestCameraUsagePermission(
  onOpenCamera: @escaping () -> Void,
  openCameraAccessModal: () -> Void
  ) {
  let status = AVCaptureDevice.authorizationStatus(for: .video)
  switch status {
  case .authorized:
    onOpenCamera()
    return
  case .notDetermined:
    AVCaptureDevice.requestAccess(for: .video, completionHandler: { isAuthorised in
      if !isAuthorised { return }
      DispatchQueue.main.async {
        onOpenCamera()
      }
    })
  case .denied:
    openCameraAccessModal()
  default: return
  }
}

func requestLibraryUsagePermission(
  onOpenLibrary: @escaping () -> Void,
  openLibraryAccessModal: () -> Void
  ) {
  let status = PHPhotoLibrary.authorizationStatus()
  switch status {
  case .authorized:
    onOpenLibrary()
    return
  case .notDetermined:
    PHPhotoLibrary.requestAuthorization({ authStatus in
      if authStatus != .authorized { return }
      DispatchQueue.main.async {
        onOpenLibrary()
      }
    })
  case .denied:
    openLibraryAccessModal()
  default: return
  }
}

enum ImageSource: CaseIterable {
  case camera, library

  var type: UIImagePickerController.SourceType {
    switch self {
    case .camera:
      return .camera
    case .library:
      return .photoLibrary
    }
  }
}

protocol ImagePickerViewModelDelegate: class {
  func viewModel(
    _: ImagePickerViewModel,
    didLoadAssets: PHFetchResult<PHAsset>,
    whereSelected: [Int]
  )
  func viewModel(_: ImagePickerViewModel, didSelectImageAt: Int)
}
