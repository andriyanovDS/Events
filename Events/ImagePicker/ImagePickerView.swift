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

class ImagePickerView: UIView, ImagePickerActionsViewDelegate {
  var actionsView: ImagePickerActionsView!
  let closeButton: ImagePickerItem
  var state: ImagePickerState = .preview
  private let contentView = UIView()
  private let onSelectImageSource: (ImageSource) -> Void
  private let onConfirmSendImages: () -> Void

  init(
    onSelectImageSource: @escaping (ImageSource) -> Void,
    onConfirmSendImages: @escaping () -> Void
    ) {
    self.onSelectImageSource = onSelectImageSource
    self.onConfirmSendImages = onConfirmSendImages
    closeButton = ImagePickerItem(
      action: .close,
      labelText: NSLocalizedString(
        "Close",
        comment: "Image picker: close"
      ),
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

  func onSelectAction(_ action: ImagePickerAction) {
    switch action {
    case .openCamera:
      onSelectImageSource(.camera)
    case .openLibrary:
      onSelectImageSource(.library)
    case .selectImages:
      onConfirmSendImages()
      return
    default:
      return
    }
  }

  func updateImagePreviews(selectedImageIndices: [Int]) {
    actionsView.collectionView.visibleCells
      .compactMap { $0 as? ImagePreviewCell }
      .forEach({ v in
        guard let indexPath = actionsView.collectionView.indexPath(for: v) else {
          return
        }
        guard let selectedImageIndex = selectedImageIndices.firstIndex(of: indexPath.item) else {
          v.selectedCount = 0
          return
        }
        v.selectedCount = selectedImageIndex + 1
      })
    changeFirstAction(selectedImageCount: selectedImageIndices.count)
  }

  func collectionViewDidScroll() {
    actionsView.adjustImageViewSelectButtonAfterScroll()
  }

  func onImageDidSelected(at index: Int, selectedImageIndices: [Int]) {
    updateImagePreviews(selectedImageIndices: selectedImageIndices)

    if selectedImageIndices.count == 0 {
      setupPreviewView(activeIndex: index)
      return
    }
    if selectedImageIndices.count == 1 && state == .preview {
      setupSelectImageView(activeIndex: index)
      return
    }
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsView.scrollToSelectedImageView(at: index, scale: 1.0)
      self.layoutIfNeeded()
    })
    return
  }

  private func setupView() {
    backgroundColor = .gray900(alpha: 0.4)
    closeButton.layer.cornerRadius = 10
    actionsView = ImagePickerActionsView()
    actionsView.delegate = self
    sv(contentView.sv(actionsView, closeButton))
    setupConstraints()
  }

  private func setupConstraints() {
    contentView.left(10).right(10).height(PICKER_HEIGHT).bottom(-PICKER_HEIGHT)
    closeButton.left(0).right(0).bottom(0).height(PICKER_ACTION_BUTTON_HEIGHT)
    actionsView.left(0).right(0).height(200)
    actionsView.Bottom == closeButton.Top - 15
  }

  private func setupSelectImageView(activeIndex: Int) {
    state = .selectImage
    let scale = state.scale()
    changeFirstAction(selectedImageCount: 1)
    actionsView.layout.cellWidthForContentSizeCalculation = PICKER_IMAGE_WIDTH + PICKER_ACTION_BUTTON_HEIGHT
    actionsView.layout.invalidateLayout()
    actionsView.layoutIfNeeded()
    actionsView.layout.cellSize = CGSize(
      width: PICKER_IMAGE_WIDTH + PICKER_ACTION_BUTTON_HEIGHT,
      height: PICKER_IMAGE_HEIGHT + PICKER_ACTION_BUTTON_HEIGHT
    )
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsView.collectionView.heightConstraint?.constant += PICKER_ACTION_BUTTON_HEIGHT
      let contentOffsetX = self.actionsView.scrollToSelectedImageView(at: activeIndex, scale: scale)
      self.actionsView.adjustImageViewSelectButton(contentOffsetX: contentOffsetX)
      self.layoutIfNeeded()
    })
  }

  private func changeFirstAction(selectedImageCount: Int) {
    let changedAction = actionsView.actions[0]
    if selectedImageCount == 0 {
      changedAction.action = .openCamera
      changedAction.labelText = ImageSource.camera.localizedString()
      return
    }
    let formatString = NSLocalizedString("image count", comment: "Image picker: select image")
    changedAction.action = .selectImages
    changedAction.labelText = NSLocalizedString("Select", comment: "Select images")
      + " "
      + String.localizedStringWithFormat(formatString, selectedImageCount)
  }

  private func setupPreviewView(activeIndex: Int) {
    state = .preview
    self.changeFirstAction(selectedImageCount: 0)
    actionsView.layout.cellWidthForContentSizeCalculation = PICKER_IMAGE_WIDTH
    actionsView.layout.cellSize = CGSize(
      width: PICKER_IMAGE_WIDTH,
      height: PICKER_IMAGE_HEIGHT
    )
    let scale = state.scale()
    UIView.animate(withDuration: 0.2, animations: {
      self.actionsView.collectionView.heightConstraint?.constant = 100
      let contentOffsetX = self.actionsView.scrollToSelectedImageView(
        at: activeIndex,
        scale: scale
      )
      self.actionsView.adjustImageViewSelectButton(contentOffsetX: contentOffsetX)
      self.layoutIfNeeded()
    })
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
