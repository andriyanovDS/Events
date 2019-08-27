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

  override func viewDidLoad() {
    super.viewDidLoad()

    setupView()
    viewModel = ImagePickerViewModel(
      setupGalleryImage: setupGalleryImage,
      targetSize: CGSize(width: PICKER_IMAGE_WIDTH + 50, height: PICKER_IMAGE_HEIGHT + 50)
    )

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

  private func setupView() {
    imagePickerView = ImagePickerView(
      onSelectImageSource: onSelectImageSource,
      onSelectImage: onSelectImage
    )
    imagePickerView?.actionsView?.scrollView.delegate = self
    imagePickerView?.closeButton.addTarget(
      self,
      action: #selector(onClose),
      for: .touchUpInside
    )
    view = imagePickerView
  }

  @objc func onClose() {
    // TODO: move to coordinator
    imagePickerView?.animateHideContent(onComplete: {
      self.dismiss(animated: false, completion: nil)
    })
  }
}

extension ImagePickerVC: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.y = 0
  }
}
