//
//  ProfileActionSection.swift
//  Events
//
//  Created by Дмитрий Андриянов on 29/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import SwiftIconFont

class ProfileActionButton: UIButton {
  
  let labelText: String
  let subtitleText: String?
  let iconName: String
  
  let label = UILabel()
  let iconImageView = UIImageView()
  lazy var subtitleLabel = UILabel()
  
  override var bounds: CGRect {
    didSet {
      _ = addBorder(
        toSide: .bottom,
        withColor: UIColor.border.cgColor,
        andThickness: 1.0
      )
    }
  }
  
  init(labelText: String, subtitleText: String?, iconName: String) {
    self.labelText = labelText
    self.subtitleText = subtitleText
    self.iconName = iconName
    super.init(frame: CGRect())
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    height(70)
    
    sv(label, iconImageView)
    setupLabel()
    setupIcon()
    
    if let subtitle = subtitleText {
      setupSubtitle(text: subtitle)
    }
  }
  
  private func setupLabel() {
    styleText(
      label: label,
      text: labelText,
      size: 18,
      color: .fontLabel,
      style: .medium
    )
    label.left(0).centerVertically(0)
  }
  
  private func setupSubtitle(text: String) {
    styleText(
      label: subtitleLabel,
      text: text,
      size: 18,
      color: .fontLabel,
      style: .medium
    )
    label.sv(subtitleLabel)
    subtitleLabel
      .top(7)
      .left(0)
  }
  
  private func setupIcon() {
    let image = UIImage(
      from: .materialIcon,
      code: iconName,
      textColor: UIColor.fontLabel,
      backgroundColor: .clear,
      size: CGSize(width: 35, height: 35)
    )
    iconImageView.image = image
    iconImageView
      .right(0)
      .centerVertically(0)
  }
}
