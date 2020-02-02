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
  var images: [UIImage] = []
  var selectedImageIndices: [Int] = []
  weak var delegate: ImagePickerViewModelDelegate?
  private let disposeBag = DisposeBag()
  private let loadLocalImage$ = PublishSubject<PHAsset>()

  init(onResult: @escaping (([UIImage]) -> Void)) {
    self.onResult = onResult

    let requestOptions = PHImageRequestOptions()
    requestOptions.version = .current
    requestOptions.deliveryMode = .highQualityFormat
    requestOptions.isSynchronous = false
    let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    loadLocalImage$
      .buffer(
        timeSpan: DispatchTimeInterval.milliseconds(100),
        count: 30,
        scheduler: backgroundScheduler
      )
      .observeOn(backgroundScheduler)
      .concatMap {[weak self] in Observable
        .from($0)
        .flatMap {[weak self] asset -> Observable<UIImage> in
          guard let size = self?.targetSize else {
            return Observable<UIImage>.never()
          }
          return Observable<UIImage>.create { observer in
            PHImageManager.default().requestImage(
              for: asset,
              targetSize: size,
              contentMode: .aspectFit,
              options: requestOptions
            ) { image, _ in
              image.foldL(
                none: { observer.on(.completed) },
                some: {
                  observer.on(.next($0))
                  observer.on(.completed)
                }
              )
            }
            return Disposables.create()
          }
        }
      }
      .observeOn(MainScheduler.instance)
      .subscribe {[weak self] event in
        switch event {
        case .next(let image):
          self?.onRequestedImageDidLoad(image)
        default: break
        }
      }
      .disposed(by: disposeBag)
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
    onResult(selectedImageIndices.map { images[$0] })
    steps.accept(EventStep.imagePickerDidComplete)
  }

  private func handleCamera() {

  }

  func closeImagePicker(with result: [UIImage]) {
    self.onResult(result)
    self.steps.accept(EventStep.imagePickerDidComplete)
  }

  func openImagesPreview(startAt index: Int) {
    steps.accept(EventStep.imagesPreview(
      images: images,
      startAt: index,
      selectedImageIndices: selectedImageIndices,
      onResult: {[weak self] selectedImageIndices in
        self?.selectedImageIndices = selectedImageIndices
        self?.delegate?.updateImagePreviews(selectedImageIndices: selectedImageIndices)
      }
    ))
  }

  private func onRequestedImageDidLoad(_ image: UIImage) {
    delegate?.prepareImagesUpdate()
    images.append(image)
    delegate?.insertImage(at: self.images.count - 1)
  }

  private func handleLibrary() {
    let fetchOptions = PHFetchOptions()
    let images = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    images.enumerateObjects(
      options: [NSEnumerationOptions.reverse],
      using: {[weak self] asset, index, _ in
        self?.loadLocalImage$.on(.next(asset))
        if index == 0 {
          self?.loadLocalImage$.on(.completed)
        }
      }
    )
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
  func prepareImagesUpdate()
  func insertImage(at index: Int)
  func updateImagePreviews(selectedImageIndices: [Int])
  func performCloseAnimation(onComplete: @escaping () -> Void)
}
