//
//  EventNameView.swift
//  Events
//
//  Created by Dmitry on 06.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EventNameView: UIView {
	let nameTextView = UITextView()
	let closeButton = UIButtonScaleOnPress()
	let submitButton = ButtonScale()
	private let titleLabel = UILabel()
	private let contentView = UIView()
	
	init() {
		super.init(frame: CGRect.zero)
		setupView()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func keyboardHeightDidChange(_ info: KeyboardAttachInfo?) {
		let durationOption = info?.duration
    let duration = durationOption
      .map { max(0.2, $0) }
      .getOrElse(result: 0.2)
		UIView.animate(withDuration: duration, animations: {
      let bottomConstraint = info
				.map(\.height)
				.map { $0 - self.safeAreaInsets.bottom + 5 }
        .getOrElse(result: 20)
      self.submitButton.bottomConstraint?.constant = -bottomConstraint
      self.layoutIfNeeded()
    })
	}
	
	private func setupView() {
		backgroundColor = .white
		styleText(
			label: titleLabel,
			text: NSLocalizedString(
				"Event name",
				comment: "Event name: title"
			),
			size: 24,
			color: .black,
			style: .bold
		)
		
		styleText(
			button: submitButton,
			text: NSLocalizedString("Done", comment: "Event name: submit button label"),
			size: 18,
			color: .white,
			style: .medium
		)
		submitButton.backgroundColor = .blue()
		
		styleText(
			textView: nameTextView,
			text: "",
			size: 22,
			color: .black,
			style: .regular
		)
		
		closeButton.style { v in
			styleIcon(button: v, iconCode: "close", size: 20.0, color: .gray600())
			v.backgroundColor = .gray200()
			v.layer.cornerRadius = 15
		}
		contentView.sv([titleLabel, closeButton, nameTextView, submitButton])
		sv(contentView)
	}
	
	private func setupConstraints() {
		contentView.Top == safeAreaLayoutGuide.Top
		contentView.Bottom == safeAreaLayoutGuide.Bottom
		contentView.left(0).right(0)
		titleLabel.top(20).centerHorizontally()
		closeButton
			.right(20)
			.width(30)
			.height(30)
			.CenterY == titleLabel.CenterY
		nameTextView.left(10).right(10).Top == titleLabel.Bottom + 20
		nameTextView.Bottom == submitButton.Top - 15
		submitButton
			.width(150)
			.centerHorizontally()
			.bottom(20)
	}
}
