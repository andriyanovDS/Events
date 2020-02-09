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
  private let onResult: ([PHAsset]) -> Void

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
  var selectedImageIndices: [Int] = []
  weak var delegate: ImagePickerViewModelDelegate?
	private var assets: PHFetchResult<PHAsset>?
	private var lastCachedAssetIndex: Int = 0
	private let imageRequestOptions = PHImageRequestOptions()
	private let imageManager = PHImageManager()
	var assetsCount: Int {
		assets?.count ?? 0
	}

  init(onResult: @escaping (([PHAsset]) -> Void)) {
    self.onResult = onResult

    imageRequestOptions.version = .current
    imageRequestOptions.deliveryMode = .highQualityFormat
    imageRequestOptions.isSynchronous = false
  }
	
	func getImage(at index: Int, onResult: @escaping (UIImage) -> Void) {
		guard let asset = assets.map({ $0.object(at: index) }) else { return }

		imageManager.requestImage(
			for: asset,
			targetSize: targetSize,
			contentMode: .aspectFill,
			options: imageRequestOptions,
			resultHandler: { imageNullable, _ in
				imageNullable.foldL(none: {}, some: onResult)
		  }
		)
	}
  
  func onSelectImageSource(source: ImageSource) {
    switch source {
    case .camera:
      openCamera()
    case .library:
      openLibrary()
    }
  }

  func onSelectImage(at index: Int) {
    if let selectedImageIndex = selectedImageIndices.firstIndex(of: index) {
      selectedImageIndices.remove(at: selectedImageIndex)
    } else {
      selectedImageIndices.append(index)
    }
  }

  func onConfirmSendImages() {
    delegate?.performCloseAnimation {[weak self] in
      self?.onCloseAnimationDidComplete()
    }
  }

  private func onCloseAnimationDidComplete() {
		defer {
			steps.accept(EventStep.imagePickerDidComplete)
		}
		
		guard let imageAssets = assets else {
			return
		}
		onResult(
			selectedImageIndices.map { imageAssets.object(at: $0) }
		)
  }

  private func handleCamera() {

  }

  func closeImagePicker(with result: [PHAsset]) {
    self.onResult(result)
    self.steps.accept(EventStep.imagePickerDidComplete)
  }

  func openImagesPreview(startAt index: Int) {
		guard let assets = assets else { return }
    steps.accept(EventStep.imagesPreview(
      assets: assets,
      startAt: index,
      selectedImageIndices: selectedImageIndices,
      onResult: {[weak self] selectedImageIndices in
        self?.selectedImageIndices = selectedImageIndices
        self?.delegate?.updateImagePreviews(selectedImageIndices: selectedImageIndices)
      }
    ))
  }

  private func handleLibrary() {
    let fetchOptions = PHFetchOptions()
		let sortByDateDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
		fetchOptions.sortDescriptors = [sortByDateDescriptor]
    assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
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
    AVCaptureDevice.requestAccess(for: .video, completionHandler: { isAuthorized in
      if !isAuthorized {
        return
      }
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

  func localizedString() -> String {
    switch self {
    case .camera: return NSLocalizedString(
      "Camera",
      comment: "Image picker: open camera"
    )
    case .library: return NSLocalizedString(
      "Gallery",
      comment: "Image picker: open gallery"
    )
    }
  }
}

protocol ImagePickerViewModelDelegate: UIImagePickerControllerDelegate,
  UIViewController,
  UINavigationControllerDelegate {
  func updateImagePreviews(selectedImageIndices: [Int])
  func performCloseAnimation(onComplete: @escaping () -> Void)
}
