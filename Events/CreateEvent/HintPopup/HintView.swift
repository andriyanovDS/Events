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
  private let popup: HintPopup
  private let contentView = UIView()
  private let label = UILabel()
  private let descriptionLabel = UILabel()
  private let linkLabel = UILabel()

  init(popup: HintPopup) {
    self.popup = popup
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
      text: popup.title,
      size: 18,
      color: UIColor.gray900(),
      style: .bold
    )
    styleText(
      label: descriptionLabel,
      text: popup.description,
      size: 16,
      color: .gray600(),
      style: .medium
    )
    styleText(
      label: linkLabel,
      text: popup.link,
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
    [label, descriptionLabel, linkLabel].forEach { $0.textAlignment = .center }
  }

  private func setupConstraints() {
    contentView
      .centerInContainer()
      .fillContainer()

    label.top(10).left(15).right(15)
    align(vertically: [label, descriptionLabel, linkLabel])
    layout(
      |-label-|,
      10,
      |-15-descriptionLabel-15-|,
      10,
      |-linkLabel.bottom(10)-|
    )
  }
}
