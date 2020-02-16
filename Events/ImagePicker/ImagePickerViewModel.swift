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

class ImagePickerViewModel: Stepper {
  let steps = PublishRelay<Step>()
  private let onResult: ([PHAsset]) -> Void

  var targetSize: CGSize = CGSize.zero {
    didSet {
      self.imageCacheManager.setTargetSize(self.targetSize)
    }
  }
  var selectedImageIndices: [Int] = []
  weak var delegate: ImagePickerViewModelDelegate?
  private let imageCacheManager: ImageCacheManager
	private var assets: PHFetchResult<PHAsset>?
	private var lastCachedAssetIndex: Int = 0
	private let imageRequestOptions = PHImageRequestOptions()
  private var previousPreheatRect = CGRect.zero
	var assetsCount: Int {
		assets?.count ?? 0
	}

  init(onResult: @escaping (([PHAsset]) -> Void)) {
    self.onResult = onResult
    imageCacheManager = ImageCacheManager(targetSize: targetSize, imageRequestOptions: nil)
  }

  func onViewReady() {
    requestLibraryUsagePermission(
      onOpenLibrary: handleLibrary,
      openLibraryAccessModal: {
        self.steps.accept(EventStep.permissionModal(withType: .library))
      }
    )
  }

  func asset(at index: Int) -> PHAsset {
    assets!.object(at: index)
  }

  func image(for asset: PHAsset, onResult: @escaping (UIImage) -> Void) {
    return imageCacheManager.getImage(for: asset, onResult: onResult)
  }

  func attemptToCacheAssets(_ collectionView: UICollectionView) {
    guard let assets = self.assets else { return }
    imageCacheManager.attemptToCacheAssets(collectionView, assets: assets)
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
    delegate?.onImageDidSelected(at: index)
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
		let indices = selectedImageIndices

    loadSharedImage(for: asset(at: index), onResult: {[weak self] image, isICloudAsset in
      self?.steps.accept(EventStep.imagesPreview(
        assets: assets,
        sharedImage: SharedImage(index: index, image: image, isICloudAsset: isICloudAsset),
        selectedImageIndices: indices,
        onImageDidSelected: {[weak self] index in
          self?.onSelectImage(at: index)
        }
      ))
    })
  }

  private func loadSharedImage(for asset: PHAsset, onResult: @escaping (UIImage, Bool) -> Void) {
    let options = PHImageRequestOptions()
    options.isSynchronous = false
    options.deliveryMode = .highQualityFormat
    let scale = UIScreen.main.scale
    PHImageManager.default().requestImage(
      for: asset,
      targetSize: CGSize(
        width: UIScreen.main.bounds.width * scale,
        height: UIScreen.main.bounds.height * scale
      ),
      contentMode: .aspectFit,
      options: options,
      resultHandler: {[weak self] image, _ in
        image.foldL(
          none: {
            self?.imageCacheManager.getImage(for: asset, onResult: { image in
              onResult(image, true)
            })
          },
          some: { onResult($0, false) }
        )
      }
    )
  }

  private func handleLibrary() {
    let fetchOptions = PHFetchOptions()
    fetchOptions.includeAssetSourceTypes = .typeUserLibrary
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
  func onImageDidSelected(at index: Int)
  func updateImagePreviews(selectedImageIndices: [Int])
  func performCloseAnimation(onComplete: @escaping () -> Void)
}
