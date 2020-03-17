//
//  StartView.swift
//  Events
//
//  Created by Dmitry on 15.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class StartView: UIView {
	let submitButton = ButtonScale()
	let publicSwitch = UISwitch()
	let titleTextField = UITextField()
	var isPublic: Bool = true {
		didSet {
			publicLabel.textColor = publicLabelColor
		}
	}
	private let titleLabel = UILabel()
	private let publicLabel = UILabel()
	private var publicLabelColor: UIColor {
		isPublic
			? .gray400()
			: .black
	}
	
	init() {
		super.init(frame: CGRect.zero)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		backgroundColor = .white
		styleText(
      button: submitButton,
      text: NSLocalizedString("Next step", comment: "Create event: next step"),
      size: 20,
      color: .white,
      style: .medium
    )
		submitButton.isEnabled = false
    submitButton.backgroundColor = UIColor.blue()
		sv(submitButton)
		
		setupTitleSection()
		setupPublishSection()
		setupConstraints()
	}
	
	private func setupTitleSection() {
		styleText(
			label: titleLabel,
			text: NSLocalizedString(
        "What will the event be called?",
        comment: "Create event: event title label"
      ),
			size: 26,
			color: .black,
			style: .bold
		)
		titleLabel.numberOfLines = 2
		styleText(
      textField: selectTextFieldStyle(titleTextField),
      text: NSLocalizedString(
        "Some cool name...",
        comment: "Create event: event title text field placeholder"
      ),
      size: 22,
      color: .black,
      style: .bold
    )
		sv([titleLabel, titleTextField])
	}
	
	private func setupPublishSection() {
		styleText(
			label: publicLabel,
			text: NSLocalizedString(
        "Private event",
        comment: "Create event: public label"
      ),
			size: 20,
			color: publicLabelColor,
			style: .bold
		)
		
		publicSwitch.isOn = !isPublic
		sv([publicLabel, publicSwitch])
	}
	
	private func setupConstraints() {
		submitButton
			.centerHorizontally()
			.bottom(75)
			.width(200)
		
		titleLabel.top(30%).left(20).right(20)
		titleTextField
			.left(20)
			.right(20)
			.height(40)
			.Top == titleLabel.Bottom + 20
		
		publicSwitch
			.right(20)
			.Top == titleTextField.Bottom + 40
		
		publicLabel
			.left(20)
			.CenterY == publicSwitch.CenterY
	}
}

extension StartView: ViewWithKeyboard {
	func keyboardHeightDidChange(_ info: KeyboardAttachInfo?) {
		UIView.animate(withDuration: info?.duration ?? 0.2, animations: {
      let bottomConstraint = info
        .map { $0.height + 15.0 }
        .getOrElse(result: 75)
      self.submitButton.bottomConstraint?.constant = -bottomConstraint
      self.layoutIfNeeded()
    })
	}
}
