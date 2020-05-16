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
  var count: Int? {
    didSet {
      countDidChange(from: oldValue, to: count)
    }
  }

  init(size: CGSize) {
    super.init(frame: CGRect.zero)
		setupView(with: size)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func countDidChange(from: Int?, to: Int?) {
    guard from != to else { return }
    if let currentValue = to {
      setCount(currentValue)
      return
    }
    clearCount()
  }

  private func clearCount() {
    backgroundColor = .clear
    setTitle("", for: .normal)
  }

  private func setCount(_ count: Int) {
    backgroundColor = .blueButtonBackground
    setTitle(count.description, for: .normal)
  }

  private func setupView(with size: CGSize) {
    style { v in
			v.height(size.height).width(size.width)
			v.layer.cornerRadius = size.width / 2
      v.layer.borderWidth = 2
      v.layer.borderColor = UIColor.background.cgColor
		}

    styleText(
      button: self,
      text: "",
      size: 14,
      color: .blueButtonFont,
      style: .bold
    )
  }
}
