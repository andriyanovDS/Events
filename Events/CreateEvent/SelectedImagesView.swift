//
//  SelectedImagesView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 01/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class SelectedImagesView: UIView {
  let openImagePickerButton = UIButton()
  private lazy var imagesStackView = UIStackView()
  private lazy var imagesScrollView = UIScrollView()
  private var selectedImages: [UIImage] = []

  func handleImagePickerResult(images: [UIImage]) {
    if images.count == 0 {
      return
    }
    if self.selectedImages.count == 0 {
      self.openImagePickerButton.removeFromSuperview()
      self.setupImageViews(with: images)
      self.selectedImages = images
      return
    }
    self.selectedImages.append(contentsOf: images)
    images.forEach { self.addSelectedImage($0) }
  }

  private func addSelectedImage(_ image: UIImage) {
    let imageContentView = UIView()
    let imageView = UIImageView(image: image)
    let removeButton = UIButtonScaleOnPress()
    imageView.style({ v in
      v.clipsToBounds = true
      v.contentMode = .scaleAspectFill
      v.layer.cornerRadius = 10
    })
    removeButton.style({ v in
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
    })
    removeButton.uniqueData = image
    removeButton.addTarget(self, action: #selector(onPressRemoveButton(_:)), for: .touchUpInside)
    imageContentView.sv(imageView, removeButton)
    imageView.fillContainer().centerInContainer()
    removeButton.right(4).top(4).width(20).height(20)
    imagesStackView.addArrangedSubview(imageContentView)
    imageContentView.width(100).height(80)
  }

  private func setupImageViews(with images: [UIImage]) {
    imagesScrollView.showsHorizontalScrollIndicator = false
    imagesScrollView.canCancelContentTouches = true
    imagesStackView.style({ v in
      v.axis = .horizontal
      v.alignment = .fill
      v.distribution = .fillEqually
      v.spacing = 5
    })
    images.forEach { addSelectedImage($0) }
    sv(imagesScrollView.sv(imagesStackView))
    imagesScrollView.fillContainer().centerInContainer()
    imagesStackView.top(5).right(5).left(5).bottom(5)
    heightConstraint?.constant = 90
  }

  private func removeSelectedImage(inside view: UIView) {
    UIView.animate(withDuration: 0.1, animations: {
      view.alpha = 0
      self.layoutIfNeeded()
    }, completion: { _ in
      UIView.animate(withDuration: 0.2, animations: {
        self.imagesStackView.removeArrangedSubview(view)
        self.layoutIfNeeded()
      }, completion: { _ in
        if self.selectedImages.count == 0 {
          self.heightConstraint?.constant = 0
          UIView.animate(withDuration: 0.1, animations: {
            self.superview?.layoutIfNeeded()
          })
        }
      })
    })
  }

  @objc private func onPressRemoveButton(_ button: UIButtonScaleOnPress) {
    guard let image = button.uniqueData as? UIImage else {
      return
    }
    let index = selectedImages.firstIndex(of: image)
    selectedImages = selectedImages.filter { $0 != image }
    let removedView = imagesStackView.arrangedSubviews[index!]
    self.removeSelectedImage(inside: removedView)
  }
}
