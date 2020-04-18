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
  private let sfSymbol: String
  
  init(material: String, sfSymbol: String) {
    self.material = material
    self.sfSymbol = sfSymbol
  }
  
  init(code: String) {
    self.init(material: code, sfSymbol: code)
  }
  
  @available(iOS 13, *)
  func sfSymbolImage(pointSize: CGFloat, color: UIColor) -> UIImage? {
    let configuration = UIImage.SymbolConfiguration(pointSize: pointSize)
    return UIImage(systemName: sfSymbol, withConfiguration: configuration)?.withTintColor(color)
  }
  
  func image(withSize size: CGFloat, andColor color: UIColor) -> UIImage? {
    if #available(iOS 13, *) {
      return sfSymbolImage(pointSize: size * 0.7, color: color)
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
    if #available(iOS 13, *) {
      let image = icon.sfSymbolImage(pointSize: size, color: color)
      setImage(image, for: .normal)
    } else {
      let image = icon.image(withSize: size, andColor: color)
      setImage(image, for: .normal)
    }
    tintColor = color
  }
}

extension UIContextualAction {
  func setIcon(_ icon: Icon, size: CGFloat, color: UIColor = .fontLabel) {
    image = icon.image(withSize: size, andColor: color)
  }
}
