//
//  Icon.swift
//  Events
//
//  Created by Dmitry on 17.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

struct Icon {
  private let material: String
  private let sfSymbol: String?
  
  init(material: String, sfSymbol: String? = nil) {
    self.material = material
    self.sfSymbol = sfSymbol
  }
  
  init(code: String) {
    self.init(material: code, sfSymbol: code)
  }
  
  @available(iOS 13, *)
  func sfSymbolImage(pointSize: CGFloat, color: UIColor) -> UIImage? {
    guard let symbol = sfSymbol else { return nil }
    let configuration = UIImage.SymbolConfiguration(pointSize: pointSize)
    return UIImage(systemName: symbol, withConfiguration: configuration)?.withTintColor(color)
  }
  
  func image(withSize size: CGFloat, andColor color: UIColor) -> UIImage? {
    if #available(iOS 13, *) {
      if let image = sfSymbolImage(pointSize: size * 0.7, color: color) {
        return image
      }
    }
    return UIImage(
      from: .materialIcon,
      code: material,
      textColor: color,
      backgroundColor: .clear,
      size: CGSize(width: size, height: size)
    )
  }
}

extension UIImageView {
  func setIcon(_ icon: Icon, size: CGFloat, color: UIColor = .fontLabel) {
    image = icon.image(withSize: size, andColor: color)
    tintColor = color
  }
}

extension UIButton {
  func setIcon(_ icon: Icon, size: CGFloat, color: UIColor = .fontLabel) {
    setImage(icon.image(withSize: size * 1.4, andColor: color), for: .normal)
    tintColor = color
  }
}

extension UIContextualAction {
  func setIcon(_ icon: Icon, size: CGFloat, color: UIColor = .fontLabel) {
    image = icon.image(withSize: size, andColor: color)
  }
}
