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
      _ = addBorder(toSide: .top, withColor: UIColor.gray400().cgColor, andThickness: 1)
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
  }

  private func setupView() {
    height(60)
    styleText(
      button: clearButton,
      text: NSLocalizedString("Clear", comment: "Calendar: clear dates"),
      size: 15,
      color: .black,
      style: .medium
    )

    clearButton.setTitleColor(UIColor.gray400(), for: .disabled)

    styleText(
      button: saveButton,
      text: NSLocalizedString("Save", comment: "Calendar: save dates"),
      size: 14,
      color: .white,
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
      v.backgroundColor = UIColor.lightBlue()
      v.layer.cornerRadius = 5
    }
    sv(clearButton, saveButton)
    clearButton.centerVertically().left(10)
    saveButton.centerVertically().right(10)
  }
}
