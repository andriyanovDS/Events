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

class DatePickerModalViewModel: Stepper, ResultProvider {
	let steps = PublishRelay<Step>()
	var selectedDate: Date
	let mode: UIDatePicker.Mode
	let onResult: ResultHandler<Date>
	
  init(initialDate: Date, mode: UIDatePicker.Mode, onResult: @escaping ResultHandler<Date>) {
		selectedDate = initialDate
		self.mode = mode
    self.onResult = onResult
	}
	
	func submitDate() {
		onResult(selectedDate)
		steps.accept(EventStep.datePickerModalDidComplete)
	}
}
