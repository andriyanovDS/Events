//
//  ImagePreviewCell.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05/10/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit
import Stevia

class ImagePreviewCell: UICollectionViewCell {
  let previewImageView = UIImageView()
  let selectButton = SelectImageButton()

  override init(frame: CGRect) {
    super.init(frame: frame)

    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupView() {
    previewImageView.contentMode = .scaleAspectFill
    previewImageView.width(UIScreen.main.bounds.width)

    sv(previewImageView, selectButton)
    previewImageView.centerInContainer()
    selectButton.right(20)
    selectButton.Top == safeAreaLayoutGuide.Top + 20
  }

  override func prepareForReuse() {
    selectButton.clearCount()
  }
}
