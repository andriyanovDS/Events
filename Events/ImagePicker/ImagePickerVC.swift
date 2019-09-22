//
//  ImagePickerVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ImagePickerVC: UIViewController {
   let viewModel: ImagePickerViewModel
   var imagePickerView: ImagePickerView?

   init(viewModel: ImagePickerViewModel) {
     self.viewModel = viewModel
     super.init(nibName: nil, bundle: nil)
   }

   required init?(coder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
   }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    viewModel.delegate = self
    viewModel.targetSize = CGSize(width: PICKER_IMAGE_WIDTH * 4, height: PICKER_IMAGE_HEIGHT * 4)

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.imagePickerView?.animateShowContent()
    }
  }

  internal func setupGalleryImage(image: UIImage) {
    imagePickerView?.setupImageView(image: image)
  }

  private func onSelectImageSource(source: ImageSource) {
    viewModel.onSelectImageSource(source: source)
  }

  private func onSelectImage(_ image: UIImage) -> Int {
    return viewModel.onSelectImage(image)
  }

  private func onConfirmSendImages() {
    viewModel.onConfirmSendImages()
  }

  private func setupView() {
    imagePickerView = ImagePickerView(
      onSelectImageSource: onSelectImageSource,
      onSelectImage: onSelectImage,
      onConfirmSendImages: onConfirmSendImages,
      openImagesPreview: viewModel.openImagesPreview
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
      self.viewModel.closeImagePicker(with: [])
    })
  }
}

extension ImagePickerVC: ImagePickerViewModelDelegate {
  func performCloseAnimation(onComplete: @escaping () -> Void) {
    imagePickerView?.animateHideContent(onComplete: onComplete)
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
    viewModel.closeImagePicker(with: [image])
  }
}
