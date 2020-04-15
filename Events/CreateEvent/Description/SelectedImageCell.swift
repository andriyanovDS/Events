//
//  SelectedImageCell.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/02/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos.PHAsset

class SelectedImageCell: UICollectionViewCell {
  let removeButton = UIButtonScaleOnPress()
  private let imageView = UIImageView()
  
  static let reuseIdentifier = String(describing: SelectedImageCell.self)
  
  struct Constants {
    static let imageSize = CGSize(
      width: 100,
      height: 80
    )
  }

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
      v.layer.borderColor = UIColor.blueButtonFont.cgColor
      v.layer.borderWidth = 2
      v.backgroundColor = .blueButtonBackground
      let image = UIImage(
        from: .materialIcon,
        code: "close",
        textColor: .blueButtonFont,
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
