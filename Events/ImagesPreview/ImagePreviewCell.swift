//
//  ImagePreviewCell.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05/10/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class ImagePreviewCell: UICollectionViewCell {
  let previewImageView = UIImageView()

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
    sv(previewImageView)
    previewImageView.centerInContainer()
  }
}
