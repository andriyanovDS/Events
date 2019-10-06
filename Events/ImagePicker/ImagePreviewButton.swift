//
//  ImagePreviewView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

let SELECT_BUTTON_PADDING: CGFloat = 4.0

class ImagePreviewView: UIButton {
  let image: UIImage
  let selectButton = SelectImageButton()
  let previewImageView = UIImageView()
  private let onSelectImage: (ImagePreviewView) -> Void

  var selectedCount: Int = 0 {
    didSet {
      setupCountView()
    }
  }

  init(
    image: UIImage,
    onSelectImage: @escaping (ImagePreviewView) -> Void
    ) {
    self.image = image
    self.onSelectImage = onSelectImage
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    layer.cornerRadius = 10
    clipsToBounds = true
    previewImageView.contentMode = .scaleAspectFill
    previewImageView.image = image

    sv(previewImageView, selectButton)
    previewImageView.fillContainer()

    selectButton.addTarget(self, action: #selector(onTouchButton), for: .touchUpInside)
    selectButton.top(SELECT_BUTTON_PADDING).right(SELECT_BUTTON_PADDING)
  }

  private func setupCountView() {
    if selectedCount == 0 {
      selectButton.clearCount()
      return
    }
    selectButton.setCount(selectedCount)
  }

  @objc private func onTouchButton(_: UIButton) {
    onSelectImage(self)
  }
}
