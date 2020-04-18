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
    iconCode: Icon,
    value: String
  ) {
    super.init(frame: CGRect.zero)
    styleText(
      label: titleLabel,
      text: title,
      size: 16,
      color: .fontLabelDescription,
      style: .bold
    )
    styleText(
      label: valueTextLabel,
      text: value,
      size: 18,
      color: .fontLabelInverted,
      style: .medium
    )
    iconImageView.setIcon(iconCode, size: 24, color: .fontLabelDescription)
    valueTextLabel.numberOfLines = 3
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
