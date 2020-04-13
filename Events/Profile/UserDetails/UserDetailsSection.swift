//
//  UserDetailsSectionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class UserDetailsSectionView: UIView {
	private let childView: UIView
	private let label = UILabel()
  
	init(labelText: String, childView: UIView, initialTextValue: String?) {
		self.childView = childView
		super.init(frame: CGRect.zero)
		setupLabel(with: labelText)
		setupChildView(initialTextValue: initialTextValue ?? "")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLabel(with text: String) {
    styleText(
      label: label,
      text: text,
      size: 16,
      color: .fontLabelDescription,
      style: .medium
    )
    sv(label)
    label.top(0).left(10).right(0).height(15)
  }
  
	private func setupChildView(initialTextValue: String) {
		sv(childView)
		if let textField = childView as? UITextField {
			styleText(
				textField: textField,
				text: "",
				size: 18,
				color: .fontLabel,
				style: .medium
			)
			textField.text = initialTextValue
			childView.height(40)
		}
		if let textView = childView as? UITextView {
			styleText(
				textView: textView,
				text: initialTextValue,
				size: 18,
				color: .fontLabel,
				style: .medium
			)
			textView.text = initialTextValue
		}
		childView.height(40)
    childView.Top == label.Bottom + 7
    childView.bottom(0).left(0).right(0)
  }
}
