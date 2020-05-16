//
//  GalleryCarouselCell.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05/10/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit
import Stevia
import AVFoundation

class GalleryCarouselCell: UICollectionViewCell, FetchResultDataSourceCell {
  var assetIdentifier: String?
  let previewImageView = UIImageView()
  
  static var reuseIdentifier = String(describing: GalleryCarouselCell.self)

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupView() {
    previewImageView.contentMode = .scaleAspectFit

    sv(previewImageView)
    previewImageView.centerInContainer()
  }

  func setImage(_ image: UIImage) {
    let size = AVMakeRect(aspectRatio: image.size, insideRect: UIScreen.main.bounds)
    previewImageView.image = image
    previewImageView.width(size.width).height(size.height)
  }

  override func prepareForReuse() {
    assetIdentifier = nil
    previewImageView.image = nil
  }
}
