//
//  GalleryCarouselView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero

class GalleryCarouselView: UIView {
  let closeButton = UIButtonScaleOnPress()
  let backButton = UIButtonScaleOnPress()
	let selectButton: SelectImageButton
  let collectionView: UICollectionView

  init() {
    let layout = ImagePickerCollectionViewLayout(
      cellSize: UIScreen.main.bounds.size
    )
    layout.scrollDirection = .horizontal
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    selectButton = SelectImageButton(size: Constants.selectionButtonSize)
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    isOpaque = false
    backgroundColor = .backgroundInverted
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = .clear
    sv(collectionView, selectButton)
    collectionView.fillContainer().centerInContainer()
    selectButton.right(20)
    selectButton.Top == safeAreaLayoutGuide.Top + 20
    setupFooter()
  }

  private func setupFooter() {
    let footerView = UIView()
    backButton.style { v in
      v.layer.cornerRadius = 17
      v.layer.borderWidth = 2
      v.layer.borderColor = UIColor.background.cgColor
      let image = UIImage(
        from: .materialIcon,
        code: "chevron.left",
        textColor: .background,
        backgroundColor: .clear,
        size: CGSize(width: 30, height: 30)
      )
      v.setImage(image, for: .normal)
    }
    sv(footerView.sv(backButton))
    footerView.left(0).right(0).bottom(0)
    backButton.left(20).width(35).height(35).top(10)
    backButton.Bottom == footerView.safeAreaLayoutGuide.Bottom + 10
  }
}

extension GalleryCarouselView {
  struct Constants {
    static let selectionButtonSize = CGSize(width: 35, height: 35)
  }
}
