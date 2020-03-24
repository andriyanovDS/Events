//
//  EventInfoSection.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class EventInfoSection: UIStackView {
  private let titleLabel = UILabel()
  private let iconImageView = UIImageView()
  private let valueTextLabel = UILabel()

  init(
    title: String,
    iconCode: String,
    value: String
  ) {
    super.init(frame: CGRect.zero)
    styleText(
      label: titleLabel,
      text: title,
      size: 16,
      color: .gray600(),
      style: .bold
    )
    styleText(
      label: valueTextLabel,
      text: value,
      size: 18,
      color: .white,
      style: .medium
    )
    let iconImage = UIImage(
      from: .materialIcon,
      code: iconCode,
      textColor: .gray600(),
      backgroundColor: .clear,
      size: CGSize(width: 24, height: 24)
    )
    valueTextLabel.numberOfLines = 3
    iconImageView.image = iconImage
    spacing = 6
		axis = .vertical
		alignment = .leading
		addArrangedSubview(iconImageView)
		addArrangedSubview(titleLabel)
		addArrangedSubview(valueTextLabel)
  }
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
