//
//  ImagePreviewCell.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

let SELECT_BUTTON_PADDING: CGFloat = 4.0

class ImagePreviewCell: UICollectionViewCell {
  var image: UIImage?
  var assetIndentifier: String?
  let selectButton = SelectImageButton()
  let previewImageView = UIImageView()

  var selectedCount: Int = 0 {
    didSet {
      setupCountView()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

	func reuseCell(image: UIImage, index: Int) {
		selectButton.tag = index
    previewImageView.image = image
  }

  func setSelectButtonPosition(_ position: CGFloat) {
    selectButton.rightConstraint?.constant = -position
    self.layoutIfNeeded()
  }

  private func setupView() {
    layer.cornerRadius = 10
    clipsToBounds = true
    previewImageView.contentMode = .scaleAspectFill

    sv(previewImageView, selectButton)
    previewImageView.fillContainer()
    selectButton.top(SELECT_BUTTON_PADDING).right(SELECT_BUTTON_PADDING)
  }

  private func setupCountView() {
    if selectedCount == 0 {
      selectButton.clearCount()
      return
    }
    selectButton.setCount(selectedCount)
  }

  override func prepareForReuse() {
    selectedCount = 0
  }
}
