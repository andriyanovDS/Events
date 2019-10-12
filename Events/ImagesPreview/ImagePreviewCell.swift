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
import AVFoundation

class ImagePreviewCell: UICollectionViewCell {
  var selectedCount: Int?
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

    sv(previewImageView)
    previewImageView.centerInContainer()
  }

  func setImage(image: UIImage) {
    let size = AVMakeRect(aspectRatio: image.size, insideRect: UIScreen.main.bounds)
    previewImageView.image = image
    previewImageView.width(size.width).height(size.height)
  }

  override func prepareForReuse() {
    selectedCount = nil
  }
}
