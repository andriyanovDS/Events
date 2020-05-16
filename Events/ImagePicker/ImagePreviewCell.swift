//
//  ImagePreviewCell.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ImagePreviewCell: UICollectionViewCell, FetchResultDataSourceCell {
  var image: UIImage?
  var assetIdentifier: String?
  let previewImageView = UIImageView()
  var onPressSelectButton: (() -> Void)?
  let selectButton: SelectImageButton
  var selectButtonRightPadding: CGFloat {
    selectButton.rightConstraint?.constant ?? 0
  }

  struct Constants {
    static let selectionButtonPadding: CGFloat = 4.0
    static let selectionButtonSize: CGFloat = 25.0
  }
  
  static var reuseIdentifier = String(describing: ImagePreviewCell.self)

  override init(frame: CGRect) {
		selectButton = SelectImageButton(size: CGSize(
      width: Constants.selectionButtonSize,
      height: Constants.selectionButtonSize
		))
		
    super.init(frame: frame)
    setupView()
    selectButton.addTarget(self, action: #selector(onPressButton), for: .touchUpInside)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    assetIdentifier = nil
    previewImageView.image = nil
    onPressSelectButton = nil
    selectButton.count = nil
  }
  
  func setSelectionCount(_ count: Int?) {
    selectButton.count = count
  }

	func setImage(_ image: UIImage) {
    previewImageView.image = image
  }

  func setSelectButtonPosition(_ position: CGFloat) {
    selectButton.rightConstraint?.constant = -position
    layoutIfNeeded()
  }
  
  @objc private func onPressButton() {
    onPressSelectButton?()
  }

  private func setupView() {
    layer.cornerRadius = 10
    clipsToBounds = true
    previewImageView.contentMode = .scaleAspectFill
    sv(previewImageView, selectButton)
    previewImageView.fillContainer()
    selectButton
      .top(Constants.selectionButtonPadding)
      .right(Constants.selectionButtonPadding)
  }
}
