//
//  UITextFieldExtension.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

extension UITextField {
  func setupLeftView(width: CGFloat) {
    let leftView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: bounds.height))
    equal(heights: [self, leftView])
    leftView.backgroundColor = .clear
    self.leftView = leftView
    leftViewMode = .always
  }
}
