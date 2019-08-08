//
//  font.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

func styleText(
  label: UILabel,
  text: String,
  size: CGFloat,
  color: UIColor,
  style: FontStyle
  ) {

  label.text = text
  label.textColor = color
  label.font = style.font(size: size)
}

func styleText(
  button: UIButton,
  text: String,
  size: CGFloat,
  color: UIColor,
  style: FontStyle
  ) {

  button.setTitle(text, for: .normal)
  button.setTitleColor(color, for: .normal)

  guard let label = button.titleLabel else {
    return
  }
  styleText(label: label, text: text, size: size, color: color, style: style)
}

func styleText(
  textField: UITextField,
  text: String,
  size: CGFloat,
  color: UIColor,
  style: FontStyle
  ) {
  textField.textColor = color
  textField.font = style.font(size: size)
  textField.attributedPlaceholder = NSAttributedString(
    string: text,
    attributes: [
      NSAttributedString.Key.foregroundColor: color,
      NSAttributedString.Key.font: style.font(size: size)
    ]
  )
}

enum FontStyle {
  case medium, bold, light, regular

  func font(size: CGFloat) -> UIFont {
    switch self {
    case .medium:
      return UIFont.init(name: "CeraPro-Medium", size: size)!
    case .regular:
      return UIFont.init(name: "CeraPro", size: size)!
    case .bold:
      return UIFont.init(name: "CeraPro-Bold", size: size)!
    case .light:
      return UIFont.init(name: "CeraPro-Light", size: size)!
    }
  }
}
