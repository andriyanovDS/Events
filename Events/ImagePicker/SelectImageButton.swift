//
//  SelectImageButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/10/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class SelectImageButton: UIButton {

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func clearCount() {
    backgroundColor = .clear
    setTitle("", for: .normal)
  }

  func setCount(_ count: Int) {
    backgroundColor = .blue()
    setTitle(count.description, for: .normal)
  }

  private func setupView() {
    style({ v in
     v.height(25).width(25)
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
