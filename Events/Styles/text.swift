//
//  font.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

func setMediumFont(label: UILabel, size: CGFloat) {
    label.font = UIFont.init(name: "CeraPro-Medium", size: size)
}

func setMediumFont(button: UIButton, size: CGFloat) {
    guard let label = button.titleLabel else {
        return
    }
    setMediumFont(label: label, size: size)
}

func setBoldFont(label: UILabel, size: CGFloat) {
    label.font = UIFont.init(name: "CeraPro-Bold", size: size)
}

func setBoldFont(button: UIButton, size: CGFloat) {
    guard let label = button.titleLabel else {
        return
    }
    setBoldFont(label: label, size: size)
}

func setLightFont(label: UILabel, size: CGFloat) {
    label.font = UIFont.init(name: "CeraPro-Light", size: size)
}

func setLightFont(button: UIButton, size: CGFloat) {
    guard let label = button.titleLabel else {
        return
    }
    setLightFont(label: label, size: size)
}

func setRegularFont(label: UILabel, size: CGFloat) {
    label.font = UIFont.init(name: "CeraPro-Regular", size: size)
}

func setRegularFont(button: UIButton, size: CGFloat) {
    guard let label = button.titleLabel else {
        return
    }
    setRegularFont(label: label, size: size)
}

func styleText(
    label: UILabel,
    text: String,
    size: CGFloat,
    color: UIColor,
    style: FontStyle
    ) {

    label.text = text
    label.textColor = color

    switch style {
    case .medium:
        setMediumFont(label: label, size: size)
    case .light:
        setLightFont(label: label, size: size)
    case .bold:
        setBoldFont(label: label, size: size)
    case .regular:
        setRegularFont(label: label, size: size)
    }
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

enum FontStyle {
    case medium, bold, light, regular
}
