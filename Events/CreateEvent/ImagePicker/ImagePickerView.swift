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
    UIView.animate(withDuration: 0.1, animations: {
      self.layoutIfNeeded()
    })
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
    changeHeadAction()
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
    let scale = 1 + PICKER_ACTION_BUTTON_HEIGHT / PICKER_IMAGE_WIDTH
    self.changeHeadAction()
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsView.scrollView.heightConstraint?.constant += PICKER_ACTION_BUTTON_HEIGHT
      self.actionsView.imageViews.forEach { v in
        v.heightConstraint?.constant = PICKER_IMAGE_HEIGHT + PICKER_ACTION_BUTTON_HEIGHT
        v.widthConstraint?.constant = PICKER_IMAGE_WIDTH + PICKER_ACTION_BUTTON_HEIGHT
      }
      self.actionsView.scrollToSelectedImageView(imageView: imageView, scale: scale)
      self.layoutIfNeeded()
    })
  }

  private func changeHeadAction() {
    let changedAction = actionsView.actions[0]
    if selectedImageCount == 0 {
      changedAction.action = .openCamera
      changedAction.labelText = ImageSource.camera.localizedString()
      return
    }
    changedAction.action = .selectImages
    changedAction.labelText = "Выбрать \(selectedImageCount) \(selectedImageCount > 1 ? "изображения" : "изображение")"
  }

  private func setupPreviewView(imageView: ImagePreviewView) {
    state = .preview
    self.changeHeadAction()
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsView.scrollView.heightConstraint?.constant = 100
      self.actionsView.imageViews.forEach { v in
        v.heightConstraint?.constant = PICKER_IMAGE_HEIGHT
        v.widthConstraint?.constant = PICKER_IMAGE_WIDTH
      }
      self.actionsView.scrollToSelectedImageView(
        imageView: imageView,
        scale: 1 / (1 + (PICKER_ACTION_BUTTON_HEIGHT / PICKER_IMAGE_WIDTH))
      )
      self.layoutIfNeeded()
    })
  }
}

enum ImagePickerState {
  case preview, selectImage
}
