//
//  TextFieldWithShadow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class TextFieldWithShadow: UITextField {

  var isValid: Bool = false {
    willSet (nextValue) {
      if nextValue == isValid {
        return
      }
      self.layer.borderColor = nextValue
        ? UIColor.clear.cgColor
        : UIColor.red.cgColor
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    isUserInteractionEnabled = true
    setupLeftView(width: 15)
    layer.cornerRadius = 3
    backgroundColor = .white
    layer.borderColor = UIColor.clear.cgColor
    addShadow(radius: 7, color: .black)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
