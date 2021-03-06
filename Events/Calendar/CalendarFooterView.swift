//
//  CalendarFooterView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 19/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class CalendarFooterView: UIView {
  let clearButton = UIButton()
  let saveButton = UIButtonScaleOnPress()

  override var bounds: CGRect {
     didSet {
      _ = addBorder(toSide: .top, withColor: UIColor.border.cgColor, andThickness: 1)
    }
  }

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setIsClearButtonEnabled(_ isEnabled: Bool) {
    clearButton.isEnabled = isEnabled
    clearButton.alpha = isEnabled ? 1 : 0.6
  }

  private func setupView() {
    height(60)
    styleText(
      button: clearButton,
      text: NSLocalizedString("Clear", comment: "Calendar: clear dates"),
      size: 15,
      color: .fontLabel,
      style: .medium
    )

    clearButton.setTitleColor(UIColor.fontLabelDescription.withAlphaComponent(0.8), for: .disabled)

    styleText(
      button: saveButton,
      text: NSLocalizedString("Save", comment: "Calendar: save dates"),
      size: 14,
      color: .blueButtonFont,
      style: .medium
    )
    let edgeInsets = UIEdgeInsets(
      top: 10,
      left: 15,
      bottom: 10,
      right: 15
    )
    clearButton.contentEdgeInsets = edgeInsets
    saveButton.style { v in
      v.contentEdgeInsets = edgeInsets
      v.backgroundColor = .blueButtonBackground
      v.layer.cornerRadius = 5
    }
    sv(clearButton, saveButton)
    clearButton.centerVertically().left(10)
    saveButton.centerVertically().right(10)
  }
}
