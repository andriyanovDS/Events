//
//  LoginTextField.swift
//  Events
//
//  Created by Dmitry on 26.02.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {
	enum KeyboardType {
		case email, password
		
		func placeholder() -> String {
			switch self {
			case .email:
				return "E-mail"
			case .password:
				return "Password"
			}
		}
		
		func setAttributes(_ textField: UITextField) {
			switch self {
			case .email:
				textField.keyboardType = .emailAddress
			case .password:
				textField.keyboardType = .default
				textField.isSecureTextEntry = true
			}
		}
	}
	
	let type: KeyboardType
	var isValid: Bool = true {
    willSet (nextValue) {
      if nextValue == isValid {
        return
      }
			UIView.animate(withDuration: 0.2, animations: {
				self.backgroundColor = nextValue
					? UIColor.gray200()
					: UIColor.lightRed(alpha: 0.5)
			})
    }
  }
	
	init(type: KeyboardType) {
		self.type = type
		super.init(frame: CGRect.zero)
		setupView(for: type)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView(for type: KeyboardType) {
		attributedPlaceholder = NSAttributedString(
			string: type.placeholder(),
      attributes: [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        NSAttributedString.Key.font: FontStyle.medium.font(size: 18)
      ]
    )
		loginTextFieldStyle(self)
		type.setAttributes(self)
	}
}
