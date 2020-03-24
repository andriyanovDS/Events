//
//  font.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import AsyncDisplayKit

let fontFamilyMedium = "Montserrat-Medium"
let fontFamilyMediumItalic = "Montserrat-MediumItalic"
let fontFamilyRegular = "Montserrat"
let fontFamilyItalic = "Montserrat-Italic"
let fontFamilyBold = "Montserrat-Bold"
let fontFamilyBoldItalic = "Montserrat-BoldItalic"
let fontFamilyLight = "Montserrat-Light"

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

func styleLayerBackedText(
  textNode: ASTextNode,
  text: String,
  size: CGFloat,
  color: UIColor,
  style: FontStyle
) {
//  textNode.isLayerBacked = false
  let textAttributes = [
    NSAttributedString.Key.font: style.font(size: size),
    NSAttributedString.Key.foregroundColor: color
  ]
  textNode.attributedText = NSAttributedString(string: text, attributes: textAttributes)
}

func styleText(
  buttonNode: ASButtonNode,
  text: String,
  size: CGFloat,
  color: UIColor,
  style: FontStyle
) {
  let textAttributes = [
    NSAttributedString.Key.font: style.font(size: size),
    NSAttributedString.Key.foregroundColor: color
  ]
  buttonNode.setAttributedTitle(
    NSAttributedString(string: text, attributes: textAttributes),
    for: .normal
  )
}

func styleText(
  editableTextNode: ASEditableTextNode,
  placeholderText: String,
  size: CGFloat,
  color: UIColor,
  style: FontStyle
  ) {
  editableTextNode.typingAttributes = [
     NSAttributedString.Key.foregroundColor.rawValue: color
  ]
  editableTextNode.attributedPlaceholderText = NSAttributedString(
    string: placeholderText,
    attributes: [
      NSAttributedString.Key.foregroundColor: color.withAlphaComponent(0.7),
      NSAttributedString.Key.font: style.font(size: size)
    ]
  )
}

func setStyledText(
  editableTextNode: ASEditableTextNode,
  text: String,
  size: CGFloat,
  style: FontStyle
) {
  editableTextNode.attributedText = NSAttributedString(
    string: text,
    attributes: [
      NSAttributedString.Key.font: style.font(size: size)
    ]
  )
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
