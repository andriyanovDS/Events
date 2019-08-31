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

class ImagePreviewView: UIView {
  let image: UIImage
  let selectButton = UIButton()
  private let imageView = UIImageView()
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
    imageView.contentMode = .scaleAspectFill
    imageView.image = image

    selectButton.style({ v in
      v.height(25).width(25)
      v.layer.cornerRadius = 13
      v.layer.borderWidth = 2
      v.layer.borderColor = UIColor.white.cgColor
    })
    sv(imageView, selectButton)
    styleText(
      button: selectButton,
      text: "",
      size: 14,
      color: .white,
      style: .bold
    )

    selectButton.addTarget(self, action: #selector(onTouchButton), for: .touchUpInside)

    imageView.fillContainer().centerInContainer()
    selectButton.top(SELECT_BUTTON_PADDING).right(SELECT_BUTTON_PADDING)
  }

  private func setupCountView() {
    if selectedCount == 0 {
      selectButton.backgroundColor = .clear
      selectButton.setTitle("", for: .normal)
      return
    }
    selectButton.backgroundColor = .blue()
    selectButton.setTitle(selectedCount.description, for: .normal)
  }

  @objc private func onTouchButton(_: UIButton) {
    onSelectImage(self)
  }
}
