//
//  DatePickerModalViewController.swift
//  Events
//
//  Created by Dmitry on 06.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift

class DatePickerModalViewController: BottomModalViewController<DatePickerModalView>, ViewModelBased {
	var viewModel: DatePickerModalViewModel!
	private let disposeBag = DisposeBag()
	
	override func setupView() {
		super.setupView()
	
		modalView.datePicker.datePickerMode = viewModel.mode
		modalView.datePicker.date = viewModel.selectedDate
		modalView.datePicker.rx.date
			.subscribe(onNext: {[unowned self] date in
				self.viewModel.selectedDate = date
			})
			.disposed(by: disposeBag)
		modalView.submitButton.rx.tap
			.subscribe(onNext: {[unowned self] in self.submitButtonDidPress() })
			.disposed(by: disposeBag)
	}
	
	private func submitButtonDidPress() {
		animateDisappearance {[weak self] in
			self?.viewModel.submitDate()
		}
	}
}
