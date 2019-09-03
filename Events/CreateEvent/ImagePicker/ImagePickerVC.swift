//
//  ImagePickerVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ImagePickerVC: UIViewController {
  var viewModel: ImagePickerViewModel?
  var imagePickerView: ImagePickerView?
  var imagesDidSelected: (([UIImage]) -> Void)!

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    viewModel = ImagePickerViewModel(
      setupGalleryImage: setupGalleryImage,
      targetSize: CGSize(width: PICKER_IMAGE_WIDTH + 50, height: PICKER_IMAGE_HEIGHT + 50)
    )
    viewModel?.delegate = self

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.imagePickerView?.animateShowContent()
    }
  }

  private func setupGalleryImage(image: UIImage) {
    imagePickerView?.setupImageView(image: image)
  }

  private func onSelectImageSource(source: ImageSource) {
    viewModel?.onSelectImageSource(source: source)
  }

  private func onSelectImage(_ image: UIImage) -> Int {
    guard let viewModel = self.viewModel else {
      return 0
    }
    return viewModel.onSelectImage(image)
  }

  private func onConfirmSendImages() {
    viewModel?.onConfirmSendImages()
  }

  private func setupView() {
    imagePickerView = ImagePickerView(
      onSelectImageSource: onSelectImageSource,
      onSelectImage: onSelectImage,
      onConfirmSendImages: onConfirmSendImages
    )
    imagePickerView?.closeButton.addTarget(
      self,
      action: #selector(onClose),
      for: .touchUpInside
    )
    view = imagePickerView
  }

  @objc func onClose() {
    imagePickerView?.animateHideContent(onComplete: {
      self.viewModel?.closeImagePicker()
    })
  }
}

extension ImagePickerVC: ImagePickerViewModelDelegate {
  func closeWithResult(images: [UIImage]) {
    imagePickerView?.animateHideContent(onComplete: {
      self.imagesDidSelected(images)
    })
  }

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
    defer {
      self.dismiss(animated: true, completion: nil)
    }
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      return
    }
    imagesDidSelected?([image])
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: false, completion: nil)
  }
}
