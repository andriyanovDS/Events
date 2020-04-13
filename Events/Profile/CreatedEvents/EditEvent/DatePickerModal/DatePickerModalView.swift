//
//  DatePickerModalView.swift
//  Events
//
//  Created by Dmitry on 06.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class DatePickerModalView: BottomModalView {	
	let submitButton = ButtonScale()
	let datePicker = UIDatePicker()
	
	override func setupView() {
		super.setupView()
		
		styleText(
      button: submitButton,
      text: "Done",
      size: 18,
      color: .blueButtonFont,
      style: .medium
    )
    submitButton.backgroundColor = .blueButtonBackground
		contentView.sv([datePicker, submitButton])
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		datePicker.top(20).left(10).right(10)
		submitButton.left(10).right(10)
    submitButton.Bottom == safeAreaLayoutGuide.Bottom - 10
		datePicker.Bottom == submitButton.Top - 15
	}
}
