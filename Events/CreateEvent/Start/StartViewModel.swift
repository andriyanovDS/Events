//
//  StartViewModel.swift
//  Events
//
//  Created by Dmitry on 15.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import RxCocoa

class StartViewModel: Stepper {
	let steps = PublishRelay<Step>()
	weak var delegate: StartViewModelDelegate?
	var isEventPiblic: Bool = true
	var eventName: String?
	
	func onNextScreen() {
		guard let name = eventName else { return }
		delegate?.onResult(StartViewResult(
			name: name,
			isPublic: isEventPiblic
		))
	}
}

struct StartViewResult {
	let name: String
	let isPublic: Bool
}

protocol StartViewModelDelegate: class {
  var onResult: ((StartViewResult) -> Void)! { get }
}
