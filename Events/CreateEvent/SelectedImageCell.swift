//
//  SelectedImageCell.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/02/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos.PHAsset

let SELECTED_IMAGE_SIZE = CGSize(
  width: 100,
  height: 80
)

class SelectedImageCell: UICollectionViewCell {
  let removeButton = UIButtonScaleOnPress()
  private let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
    removeButton.uniqueData = nil
  }

  func setImage(_ image: UIImage, asset: PHAsset) {
    removeButton.uniqueData = asset
    imageView.image = image
  }

  private func setupView() {
		layer.cornerRadius = 10
		clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    removeButton.style { v in
      v.layer.cornerRadius = 10
      v.layer.borderColor = UIColor.white.cgColor
      v.layer.borderWidth = 2
      v.backgroundColor = .blue()
      let image = UIImage(
        from: .materialIcon,
        code: "close",
        textColor: .white,
        backgroundColor: .clear,
        size: CGSize(width: 16, height: 16)
      )
      v.setImage(image, for: .normal)
    }
    sv(imageView, removeButton)

    imageView.fillContainer().centerInContainer()
    removeButton.right(4).top(4).width(20).height(20)
  }
}
