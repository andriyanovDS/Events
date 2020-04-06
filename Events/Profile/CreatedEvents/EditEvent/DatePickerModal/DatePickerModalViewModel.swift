//
//  DatePickerModalViewModel.swift
//  Events
//
//  Created by Dmitry on 06.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxCocoa
import RxFlow

class DatePickerModalViewModel: Stepper, ScreenWithResult {
	let steps = PublishRelay<Step>()
	var selectedDate: Date
	let mode: UIDatePicker.Mode
	var onResult: ((Date) -> Void)!
	
	init(initialDate: Date, mode: UIDatePicker.Mode) {
		selectedDate = initialDate
		self.mode = mode
	}
	
	func submitDate() {
		onResult(selectedDate)
		steps.accept(EventStep.datePickerModalDidComplete)
	}
}
