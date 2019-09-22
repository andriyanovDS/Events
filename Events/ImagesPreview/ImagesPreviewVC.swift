//
//  ImagesPreviewVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Hero

class ImagesPreviewVC: UIViewController {
  var imagesPreviewView: ImagesPreviewView?
  let images: [UIImage]
  let startAtIndex: Int
  let onResult: ([UIImage]) -> Void
  let viewModel: ImagesPreviewViewModel

  init(
    viewModel: ImagesPreviewViewModel,
    images: [UIImage],
    startAt index: Int,
    onResult: @escaping ([UIImage]) -> Void
  ) {
    self.viewModel = viewModel
    self.images = images
    startAtIndex = index
    self.onResult = onResult
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    sutupView()
  }

  private func sutupView() {
    imagesPreviewView = ImagesPreviewView(images: images, startAt: startAtIndex)
    view = imagesPreviewView
    imagesPreviewView?.backButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
  }

  @objc private func closeModal() {
    viewModel.onCloseModal()
  }
}
