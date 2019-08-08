//
//  UIViewExtension.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

extension UIView {
  
  enum BorderViewSide {
    case left, right, top, bottom
  }
  
  func addBorder(toSide side: BorderViewSide, withColor color: CGColor, andThickness thickness: CGFloat) -> CALayer {
    let border = CALayer()
    border.backgroundColor = color
    
    switch side {
    case .left: border.frame = CGRect(
      x: 0 - thickness,
      y: 0,
      width: thickness,
      height: frame.height
      )
    case .right: border.frame = CGRect(
      x: frame.width - thickness,
      y: 0,
      width: thickness,
      height: frame.height
      )
    case .top: border.frame = CGRect(
      x: 0,
      y: -thickness,
      width: frame.width,
      height: thickness
      )
    case .bottom: border.frame = CGRect(
      x: 0,
      y: frame.height - thickness,
      width: frame.width,
      height: thickness
      )}
    
    layer.addSublayer(border)
    layer.masksToBounds = true
    return border
  }
}
