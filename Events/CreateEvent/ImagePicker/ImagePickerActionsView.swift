//
//  ImagePickerActionsView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

let IMAGES_STACK_VIEW_SPACING: CGFloat = 6.0

class ImagePickerActionsView: UIView {
  let imageSize: CGSize
  let scrollView = UIScrollView()
  let imagesStackView = UIStackView()
  let actionsStackView = UIStackView()
  let onSelectImage: (ImagePreviewView) -> Void
  let onSelectAction: (ImagePickerAction) -> Void
  var actions: [ImagePickerItem] = []
  var imageViews: [ImagePreviewView] = []

  init(
    imageSize: CGSize,
    onSelectAction: @escaping (ImagePickerAction) -> Void,
    onSelectImage: @escaping (ImagePreviewView) -> Void
  ) {
    self.imageSize = imageSize
    self.onSelectImage = onSelectImage
    self.onSelectAction = onSelectAction
    super.init(frame: CGRect.zero)
    setupView()
  }

  struct ScrollToWithTimeout {
    let sctollTo: CGFloat
    let timeout: Double
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupImageButton(_ image: UIImage) {
    let imageView = ImagePreviewView(
      image: image,
      onSelectImage: onSelectImage
    )
    imagesStackView.addArrangedSubview(imageView)
    imageView.width(imageSize.width).height(imageSize.height)
    imageViews.append(imageView)
  }

   func setupActions() {
    ImageSource.allCases.enumerated().forEach { index, source in
      let button = ImagePickerItem(
        action: source == .camera
          ? ImagePickerAction.openCamera
          : ImagePickerAction.openLibrary,
        labelText: source.localizedString(),
        isBoldLabel: false,
        hasBorder: index == 0
      )
      button.addTarget(self, action: #selector(onActionDidSelected), for: .touchUpInside)
      button.height(PICKER_ACTION_BUTTON_HEIGHT)
      actionsStackView.addArrangedSubview(button)
      actions.append(button)
    }
  }

  func scrollToSelectedImageView(imageView: ImagePreviewView, scale: CGFloat) -> CGFloat {
    let rect = imagesStackView.convert(imageView.bounds, to: imageView)
    let imageIndex = imageViews.firstIndex(of: imageView) ?? 0

    if scale == 1 {
      if imageIndex == imageViews.count - 1 {
        let scrollToPointX = scrollView.contentSize.width - scrollView.bounds.width
        let scrollToPoint = CGPoint(
          x: scrollToPointX,
          y: 0
        )
        scrollView.setContentOffset(scrollToPoint, animated: false)
        return scrollToPointX
      }
      if imageIndex == 0 {
        scrollView.setContentOffset(CGPoint.zero, animated: false)
        return 0.0
      }
    }

    let halfOfScrollViewWidth = scrollView.bounds.width / 2
    let imageCenterX = abs(rect.minX) + imageView.bounds.width / 2
    let offsetDifference = imageCenterX * scale - halfOfScrollViewWidth
    let scrollToPoint = CGPoint(
      x: offsetDifference + 10,
      y: 0
    )
    scrollView.contentSize = CGSize(
      width: scrollView.contentSize.width * scale,
      height: scrollView.contentSize.height
    )
    scrollView.setContentOffset(scrollToPoint, animated: false)
    return scrollToPoint.x
  }

  @objc func onActionDidSelected(_ item: ImagePickerItem) {
    onSelectAction(item.action)
  }

  private func setupView() {
    clipsToBounds = true
    layer.cornerRadius = 10
    scrollView.style({ v in
      v.canCancelContentTouches = true
      v.showsVerticalScrollIndicator = false
      v.showsHorizontalScrollIndicator = false
      v.backgroundColor = .white
    })
    actionsStackView.style({ v in
      v.axis = .vertical
      v.alignment = .fill
      v.distribution = .fillProportionally
    })
    imagesStackView.style({ v in
      v.axis = .horizontal
      v.alignment = .fill
      v.spacing = IMAGES_STACK_VIEW_SPACING
      v.distribution = .fillEqually
    })

    setupActions()
    sv(scrollView.sv(imagesStackView), actionsStackView)
    setupConstraints()
  }

  private func setupConstraints() {
    actionsStackView.left(0).right(0)
    scrollView.height(100).left(0).right(0).top(0)
    actionsStackView.Top == scrollView.Bottom
    imagesStackView.left(10).top(10).bottom(10).right(10)
    imagesStackView.Height == scrollView.Height - 20
  }
}
