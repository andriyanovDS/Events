//
//  EditButton.swift
//  Events
//
//  Created by Dmitry on 04.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EditButton: UIButtonScaleOnPress {
  var type: EditButtonType {
    didSet {
      valueLabel.text = type.labelText
      setupSelectedState()
    }
  }
	
	private let valueLabel = UILabel()
	private lazy var iconImageView = UIImageView()
	
	init(type: EditButtonType) {
		self.type = type
		super.init(frame: CGRect.zero)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupSelectedState() {
		let stateColor = type.state.color
		layer.borderColor = stateColor.cgColor
		valueLabel.textColor = stateColor
    iconImageView.tintColor = stateColor
	}
	
	private func setupView() {
		backgroundColor = .background
		layer.borderWidth = 1
		layer.cornerRadius = 17
		
		let stateColor = type.state.color

    styleText(
      label: valueLabel,
      text: type.labelText,
      size: 13,
      color: stateColor,
      style: .medium
    )
    setupSelectedState()
    sv(valueLabel)
    valueLabel.right(10).top(6).bottom(6)

		if let icon = type.iconCode {
      iconImageView.setIcon(icon, size: 14, color: stateColor)
			sv(iconImageView)
      iconImageView.size(14)
      iconImageView.left(10).CenterY == valueLabel.CenterY
      valueLabel.Left == iconImageView.Right + 6
    } else {
      valueLabel.left(10)
    }
	}
}

extension EditButton {
  enum SelectedState {
    case selected, notSelected
    
    static func fromBool(_ value: Bool) -> Self {
      return value ? .selected : .notSelected
    }
    
    var color: UIColor {
      switch self {
      case .selected:
        return .blueButtonBackground
      case .notSelected:
        return .grayButtonBackground
      }
    }
  }
  
  enum EditButtonType {
    case
    access(isPrivate: Bool),
    date(dateLabelText: String),
    category(categoryId: CategoryId)
    
    var labelText: String {
      switch self {
      case .access(let isPublic):
        return isPublic ? "Public" : "Private"
      case .date(let dateLabelText):
        return dateLabelText
      case .category(let categoryId):
        return categoryId.translatedLabel()
      }
    }
    
    var iconCode: Icon? {
      switch self {
      case .access:
        return Icon(code: "person")
      case .date:
        return Icon(material: "today", sfSymbol: "calendar")
      case .category:
        return nil
      }
    }
    
    var state: SelectedState {
      switch self {
      case .access(let isPublic):
        return SelectedState.fromBool(!isPublic)
      case .date:
        return .selected
      case .category:
        return .selected
      }
    }
  }
}
