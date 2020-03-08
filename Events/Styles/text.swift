//
//  font.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

let fontFamilyMedium = "CeraPro-Medium"
let fontFamilyMediumItalic = "CeraPro-MediumItalic"
let fontFamilyRegular = "CeraPro"
let fontFamilyItalic = "CeraPro-Italic"
let fontFamilyBold = "CeraPro-Bold"
let fontFamilyBoldItalic = "CeraPro-BoldItalic"
let fontFamilyLight = "CeraPro-Light"

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
      NSAttributedString.Key.foregroundColor: color.withAlphaComponent(0.7),
      NSAttributedString.Key.font: style.font(size: size)
    ]
  )
}

func styleText(
  textView: UITextView,
  text: String,
  size: CGFloat,
  color: UIColor,
  style: FontStyle
  ) {
  textView.textColor = color
  textView.font = style.font(size: size)
  textView.text = text
}

enum FontStyle {
  case medium, mediumItalic, bold, boldItalic, light, regular, italic

  func font(size: CGFloat) -> UIFont {
    switch self {
    case .medium:
      return UIFont.init(name: fontFamilyMedium, size: size)!
    case .mediumItalic:
      return UIFont.init(name: fontFamilyMediumItalic, size: size)!
    case .regular:
      return UIFont.init(name: fontFamilyRegular, size: size)!
    case .italic:
      return UIFont.init(name: fontFamilyItalic, size: size)!
    case .bold:
      return UIFont.init(name: fontFamilyBold, size: size)!
    case .boldItalic:
      return UIFont.init(name: fontFamilyBoldItalic, size: size)!
    case .light:
      return UIFont.init(name: fontFamilyLight, size: size)!
    }
  }
}
