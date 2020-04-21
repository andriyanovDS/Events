//
//  EventInfoSection.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Foundation

class EventInfoSection: UIStackView {
  private let titleLabel = UILabel()
  private let iconImageView = UIImageView()
  private let valueTextLabel = UILabel()

  init(sectionType: SectionType) {
    super.init(frame: CGRect.zero)
    setupView(type: sectionType)
  }
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
  
  private func setupView(type: SectionType) {
    styleText(
      label: titleLabel,
      text: type.title,
      size: 16,
      color: .fontLabelDescription,
      style: .bold
    )
    styleText(
      label: valueTextLabel,
      text: type.valueText,
      size: 18,
      color: .fontLabel,
      style: .medium
    )
    iconImageView.setIcon(type.icon, size: 24, color: .fontLabelDescription)
    valueTextLabel.numberOfLines = 3
    spacing = 6
    axis = .vertical
    alignment = .leading
    addArrangedSubview(iconImageView)
    addArrangedSubview(titleLabel)
    addArrangedSubview(valueTextLabel)
  }
}

extension EventInfoSection {
  enum SectionType {
    case date(dateTitle: String)
    case duration(durationRangeTitle: String)
    
    var title: String {
      switch self {
      case .date:
        return NSLocalizedString("When", comment: "Event info section title: date")
      case .duration:
        return NSLocalizedString("Duration", comment: "Event info section title: time")
      }
    }
    
    var icon: Icon {
      switch self {
      case .date:
        return Icon(material: "today", sfSymbol: "calendar")
      case .duration:
        return Icon(material: "schedule", sfSymbol: "clock")
      }
    }
    
    var valueText: String {
      switch self {
      case .date(let dateTitle):
        return dateTitle
      case .duration(let durationRangeTitle):
        return durationRangeTitle
      }
    }
  }
}
