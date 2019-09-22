//
//  ImagesPreviewView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero

class ImagesPreviewView: UIView {
  let closeButton = UIButtonScaleOnPress()
  let backButton = UIButtonScaleOnPress()
  private let images: [UIImage]
  private let startAtIndex: Int

  init(images: [UIImage], startAt index: Int) {
    self.images = images
    startAtIndex = index
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .black
    let imageView = UIImageView(image: images[startAtIndex])
    imageView.hero.id = startAtIndex.description
    imageView.contentMode = .scaleToFill
    sv(imageView)
    imageView.left(0).right(0).centerInContainer()

    setupFooter()
  }

  private func setupFooter() {
    let footerView = UIView()
    backButton.style { v in
      v.layer.cornerRadius = 17
      v.layer.borderWidth = 2
      v.layer.borderColor = UIColor.white.cgColor
      let image = UIImage(
        from: .materialIcon,
        code: "chevron.left",
        textColor: .white,
        backgroundColor: .clear,
        size: CGSize(width: 30, height: 30)
      )
      v.setImage(image, for: .normal)
    }
    sv(footerView.sv(backButton))
    footerView.left(0).right(0).bottom(0)
    backButton.left(20).width(35).height(35).top(10)
    backButton.Bottom == footerView.safeAreaLayoutGuide.Bottom
  }
}
