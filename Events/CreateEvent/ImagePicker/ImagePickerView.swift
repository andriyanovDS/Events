//
//  ImagePickerView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

let PICKER_IMAGE_HEIGHT: CGFloat = 80.0
let PICKER_IMAGE_WIDTH: CGFloat = 100.0
let PICKER_ACTION_BUTTON_HEIGHT: CGFloat = 50
private let PICKER_HEIGHT: CGFloat = 265.0

class ImagePickerView: UIView {
  var actionsView: ImagePickerActionsView!
  let closeButton: ImagePickerItem
  private let contentView = UIView()
  private let onSelectImageSource: (ImageSource) -> Void
  private let onSelectImage: (UIImage) -> Int
  private var state: ImagePickerState = .preview
  private var selectedImageCount: Int = 0

  init(
    onSelectImageSource: @escaping (ImageSource) -> Void,
    onSelectImage: @escaping (UIImage) -> Int
    ) {
    self.onSelectImageSource = onSelectImageSource
    self.onSelectImage = onSelectImage
    closeButton = ImagePickerItem(
      action: .close,
      labelText: "Закрыть",
      isBoldLabel: true,
      hasBorder: false
    )
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func animateShowContent() {
    contentView.bottomConstraint?.constant = -safeAreaInsets.bottom
    UIView.animate(
      withDuration: 0.1,
      animations: {
        self.layoutIfNeeded()
      },
      completion: { _ in
        self.adjustImageViewSelectButton(
          scale: 1.0,
          contentOffsetX: 0.0
        )
      }
    )
  }

  func animateHideContent(onComplete: @escaping () -> Void) {
    contentView.bottomConstraint?.constant = PICKER_HEIGHT
    UIView.animate(
      withDuration: 0.1,
      animations: {
        self.layoutIfNeeded()
      },
      completion: { _ in
        onComplete()
      }
    )
  }

  func onSelectAction(action: ImagePickerAction) {
    switch action {
    case .openCamera:
      onSelectImageSource(.camera)
    case .openLibrary:
      onSelectImageSource(.library)
    case .selectImages:
      // TODO: add select image logic
      return
    default:
      return
    }
  }

  private func onImageDidSelected(imageView: ImagePreviewView) {
    let count = onSelectImage(imageView.image)
    let isCountDecreased = count < selectedImageCount
    selectedImageCount = count

    if isCountDecreased {
      actionsView.imageViews
        .filter { $0.selectedCount > imageView.selectedCount }
        .forEach { v in
          v.selectedCount -= 1
      }
      imageView.selectedCount = 0
    } else {
      imageView.selectedCount = count
    }

    if selectedImageCount == 0 {
      setupPreviewView(imageView: imageView)
      return
    }
    if selectedImageCount == 1 && state == .preview {
      setupSelectImageView(imageView: imageView)
      return
    }
    changeFirstAction()
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsView.scrollToSelectedImageView(imageView: imageView, scale: 1.0)
      self.layoutIfNeeded()
    })
    return
  }

  func setupImageView(image: UIImage) {
    actionsView.setupImageButton(image)
  }

  private func setupView() {
    backgroundColor = .gray900(alpha: 0.4)
    closeButton.layer.cornerRadius = 10
    actionsView = ImagePickerActionsView(
      imageSize: CGSize(width: PICKER_IMAGE_WIDTH, height: PICKER_IMAGE_HEIGHT),
      onSelectAction: onSelectAction,
      onSelectImage: onImageDidSelected
    )
    actionsView.scrollView.delegate = self
    sv(contentView.sv(actionsView, closeButton))
    setupConstraints()
  }

  private func setupConstraints() {
    contentView.left(10).right(10).height(PICKER_HEIGHT).bottom(-PICKER_HEIGHT)
    closeButton.left(0).right(0).bottom(0).height(PICKER_ACTION_BUTTON_HEIGHT)
    actionsView.left(0).right(0).height(200)
    actionsView.Bottom == closeButton.Top - 15
  }

  private func setupSelectImageView(imageView: ImagePreviewView) {
    state = .selectImage
    let scale = state.scale()
    self.changeFirstAction()
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsView.scrollView.heightConstraint?.constant += PICKER_ACTION_BUTTON_HEIGHT
      self.actionsView.imageViews.forEach { v in
        v.heightConstraint?.constant = PICKER_IMAGE_HEIGHT + PICKER_ACTION_BUTTON_HEIGHT
        v.widthConstraint?.constant = PICKER_IMAGE_WIDTH + PICKER_ACTION_BUTTON_HEIGHT
      }
      let contentOffsetX = self.actionsView.scrollToSelectedImageView(imageView: imageView, scale: scale)
      self.adjustImageViewSelectButton(scale: scale, contentOffsetX: contentOffsetX)
      self.layoutIfNeeded()
    })
  }

  private func changeFirstAction() {
    let changedAction = actionsView.actions[0]
    if selectedImageCount == 0 {
      changedAction.action = .openCamera
      changedAction.labelText = ImageSource.camera.localizedString()
      return
    }
    changedAction.action = .selectImages
    changedAction.labelText = "Выбрать \(selectedImageCount) \(selectedImageCount > 1 ? "изображения" : "изображение")"
  }

  private func rightmostImageViewIndex(scale: CGFloat, contentOffsetX: CGFloat) -> Int {
    let maxX = contentOffsetX + actionsView.scrollView.bounds.width
    let imagesCount = maxX / ((PICKER_IMAGE_WIDTH + IMAGES_STACK_VIEW_SPACING) * scale)
    let index = Int(imagesCount.rounded(.down))

    if index >= actionsView.imageViews.count {
      return actionsView.imageViews.count - 1
    }
    
    return index
  }

  private func setupPreviewView(imageView: ImagePreviewView) {
    state = .preview
    self.changeFirstAction()
    let scale = state.scale()
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsView.scrollView.heightConstraint?.constant = 100
      self.actionsView.imageViews.forEach { v in
        v.heightConstraint?.constant = PICKER_IMAGE_HEIGHT
        v.widthConstraint?.constant = PICKER_IMAGE_WIDTH
      }
      let contentOffsetX = self.actionsView.scrollToSelectedImageView(
        imageView: imageView,
        scale: scale
      )
      self.adjustImageViewSelectButton(scale: scale, contentOffsetX: contentOffsetX)
      self.layoutIfNeeded()
    }, completion: { _ in
    })
  }

  private func setSelectButtonRightPadding(
    for view: ImagePreviewView,
    with bounds: CGRect,
    contentOffsetX: CGFloat
    ) {
    let scrollViewMaxX = contentOffsetX + actionsView.scrollView.bounds.width
    let offset = scrollViewMaxX - bounds.maxX - 10
    let offsetMinX = offset - view.selectButton.bounds.width
    var resultOffset: CGFloat = offset
    if offsetMinX < -(bounds.width - SELECT_BUTTON_PADDING) {
      resultOffset = -(bounds.width - SELECT_BUTTON_PADDING - view.selectButton.bounds.width)
    }
    if offset > -SELECT_BUTTON_PADDING {
      resultOffset = -SELECT_BUTTON_PADDING
    }
    view.selectButton.rightConstraint?.constant = resultOffset
  }

  private func adjustImageViewSelectButton(scale: CGFloat, contentOffsetX: CGFloat) {
    let index = rightmostImageViewIndex(scale: scale, contentOffsetX: contentOffsetX)
    let imageView = actionsView.imageViews[index]
    let bounds = CGRect(
      x: (PICKER_IMAGE_WIDTH + IMAGES_STACK_VIEW_SPACING) * CGFloat(index) * scale,
      y: 0,
      width: PICKER_IMAGE_WIDTH * scale,
      height: 0
    )
    self.setSelectButtonRightPadding(for: imageView, with: bounds, contentOffsetX: contentOffsetX)

    actionsView.imageViews[0..<index]
      .filter({ v in
        return v.selectButton.rightConstraint?.constant != -SELECT_BUTTON_PADDING
      })
      .forEach { $0.selectButton.rightConstraint?.constant = -SELECT_BUTTON_PADDING }
  }
}

extension ImagePickerView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.y = 0
    adjustImageViewSelectButton(
      scale: state == .preview ? 1 : state.scale(),
      contentOffsetX: scrollView.contentOffset.x
    )
  }
}

enum ImagePickerState {
  case preview, selectImage

  func scale() -> CGFloat {
    switch self {
    case .preview:
      return 1 / (1 + (PICKER_ACTION_BUTTON_HEIGHT / PICKER_IMAGE_WIDTH))
    case .selectImage:
      return 1 + PICKER_ACTION_BUTTON_HEIGHT / PICKER_IMAGE_WIDTH
    }
  }
}
