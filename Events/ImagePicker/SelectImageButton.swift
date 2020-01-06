//
//  SelectImageButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/10/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

let SELECT_BUTTON_SIZE: CGFloat = 25.0

class SelectImageButton: UIButton {
  private var count: Int?

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func clearCount() {
    if count == nil {
      return
    }
    count = nil
    backgroundColor = .clear
    setTitle("", for: .normal)
  }

  func setCount(_ count: Int) {
    if self.count == count {
      return
    }
    self.count = count
    backgroundColor = .blue()
    setTitle(count.description, for: .normal)
  }

  private func setupView() {
    style({ v in
     v.height(SELECT_BUTTON_SIZE).width(SELECT_BUTTON_SIZE)
     v.layer.cornerRadius = 13
     v.layer.borderWidth = 2
     v.layer.borderColor = UIColor.white.cgColor
   })

    styleText(
      button: self,
      text: "",
      size: 14,
      color: .white,
      style: .bold
    )
  }
}
