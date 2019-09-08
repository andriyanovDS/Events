//
//  ImagesPreviewVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ImagesPreviewVC: UIViewController {
  var imagesPreviewView: ImagesPreviewView?
  let images: [UIImage]
  let startAtIndex: Int
  let onResult: ([UIImage]) -> Void

  init(images: [UIImage], startAt index: Int, onResult: @escaping ([UIImage]) -> Void) {
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
    view.backgroundColor = .white
    imagesPreviewView = ImagesPreviewView(images: images, startAt: startAtIndex)
    view = imagesPreviewView
    imagesPreviewView?.backButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
  }

  private func setupNavigationBar() {
    navigationController?.isNavigationBarHidden = true
  }

  @objc private func closeModal() {
    onResult(images)
  }
}
