//
//  SearchBarUITextField.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

extension UITextField {
  
  func addShadow(radius: CGFloat, color: UIColor) {
    self.layer.shadowRadius = radius
    self.layer.shadowOpacity = 0.3
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOffset = .zero
    self.layer.masksToBounds = false
  }
}
