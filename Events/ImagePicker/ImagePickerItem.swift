//
//  ImagePickerItem.swift
//  Events
//
//  Created by Дмитрий Андриянов on 24/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ImagePickerItem: UIButton {
  var action: ImagePickerAction
  var labelText: String {
    didSet {
      setTitle(labelText, for: .normal)
    }
  }
  private let isBoldLabel: Bool
  private let hasBorder: Bool

  override var bounds: CGRect {
    didSet {
      if !self.hasBorder {
        return
      }
      _ = addBorder(
        toSide: .bottom,
        withColor: UIColor.gray100().cgColor,
        andThickness: 1
      )
    }
  }

  init(
    action: ImagePickerAction,
    labelText: String,
    isBoldLabel: Bool,
    hasBorder: Bool
    ) {
    self.action = action
    self.labelText = labelText
    self.hasBorder = hasBorder
    self.isBoldLabel = isBoldLabel
    super.init(frame: CGRect.zero)

    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    styleText(
      button: self,
      text: labelText,
      size: 20,
      color: .blue(),
      style: isBoldLabel
        ? .bold
        : .medium
    )

    backgroundColor = .white
  }
}

enum ImagePickerAction {
  case openCamera, openLibrary, selectImages, close
}
