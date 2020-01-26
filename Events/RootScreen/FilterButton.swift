//
//  FilterButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 26/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class FilterButton: UIButton {
  var isFilterEmpty: Bool = true

  init(label: String) {
    super.init(frame: CGRect.zero)

    backgroundColor = .white
    layer.cornerRadius = 4
    layer.borderWidth = 1
    layer.borderColor = UIColor.gray600().cgColor
    styleText(
      button: self,
      text: label,
      size: 16,
      color: UIColor.gray600(),
      style: .medium
    )
    contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isHighlighted: Bool {
    didSet {
      if isFilterEmpty {
        backgroundColor = isHighlighted ? UIColor.gray200() : UIColor.white
      } else {
        backgroundColor = isHighlighted ? UIColor.blue() : UIColor.lightBlue()
      }
    }
  }
}
