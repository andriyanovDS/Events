//
//  LocationSearchView.swift
//  Events
//
//  Created by Dmitry on 28.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class LocationSearchView: UIView {
	let textField = UITextField()
	let closeButton = UIButtonScaleOnPress()
	let predictionsTableView = UITableView()
	private var deviceLocationButton: UIButton?
	
	init() {
		super.init(frame: CGRect.zero)
		
		setupView()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func showDeviceLocationIcon() -> UIButton? {
		if deviceLocationButton != nil {
			return nil
		}
		let button = UIButtonScaleOnPress()
    styleIcon(button: button, iconCode: "gps.fixed", size: 26, color: .fontLabel)
		textField.sv(button)
		button.right(10).centerVertically()
		deviceLocationButton = button
		return button
	}
	
	private func setupView() {
		backgroundColor = .background
		styleText(
			textField: selectTextFieldStyle(textField),
			text: NSLocalizedString(
				"Enter location name...",
				comment: "Search location modal: input placeholder"
			),
			size: 18,
			color: .fontLabel,
			style: .medium
		)
		let insetView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 10))
		textField.rightView = insetView
		textField.rightViewMode = .always
		styleText(
			button: closeButton,
			text: NSLocalizedString("Cancel", comment: "Search bar: close"),
			size: 17,
			color: .fontLabel,
			style: .medium
		)
		closeButton.sizeToFit()
		closeButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		predictionsTableView.showsVerticalScrollIndicator = false
		predictionsTableView.isDirectionalLockEnabled = true
		predictionsTableView.separatorStyle = .none
		
		sv(textField, closeButton, predictionsTableView)
	}
	
	private func setupConstraints() {
		layout(
			5,
			|-10-textField.height(50)-5-closeButton.width(100)-5-|,
			10,
			|-10-predictionsTableView-10-|,
			0
		)
		textField.Top == safeAreaLayoutGuide.Top + 5
	}
}
