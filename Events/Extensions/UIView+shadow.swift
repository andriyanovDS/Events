//
//  UIView+shadow.swift
//  Events
//
//  Created by Дмитрий Андриянов on 19/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

extension UIView {
  func createShadow(radius: CGFloat, color: UIColor = .black, opacity: Float = 0.3) {
    layer.shadowRadius = radius
    layer.shadowColor = color.cgColor
    layer.shadowOffset = .zero
    layer.shadowOpacity = opacity
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
  }
}
