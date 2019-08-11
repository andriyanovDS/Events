//
//  HintView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class HintView: UIView {
  let titleText: String
  let descriptionText: String
  let linkText: String
  private let contentView = UIView()
  private let label = UILabel()
  private let descriptionLabel = UILabel()
  private let linkLabel = UILabel()

  init(
    titleText: String,
    descriptionText: String,
    linkText: String
    ) {
    self.titleText = titleText
    self.descriptionText = descriptionText
    self.linkText = linkText
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .white
    layer.cornerRadius = 10
    addShadow(view: self, radius: 3)

    styleText(
      label: label,
      text: titleText,
      size: 14,
      color: UIColor.gray900(),
      style: .bold
    )
    styleText(
      label: descriptionLabel,
      text: descriptionText,
      size: 14,
      color: .gray600(),
      style: .medium
    )
    styleText(
      label: linkLabel,
      text: linkText,
      size: 14,
      color: .lightBlue(),
      style: .medium
    )
    descriptionLabel.style({ v in
      v.lineBreakMode = .byWordWrapping
      v.numberOfLines = 0
    })
    sv(contentView.sv([label, descriptionLabel, linkLabel]))
    setupConstraints()
  }

  private func setupConstraints() {
    contentView
      .centerInContainer()
      .fillContainer()
      .left(15)
      .right(15)

    label.top(10).left(0).right(0)
    align(vertically: [label, descriptionLabel, linkLabel])
    layout(
      |-label-|,
      5,
      |-descriptionLabel.left(15).right(15)-|,
      5,
      |-linkLabel.bottom(10)-|
    )
  }
}
