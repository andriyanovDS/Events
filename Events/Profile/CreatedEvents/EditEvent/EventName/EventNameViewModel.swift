//
//  EventNameViewModel.swift
//  Events
//
//  Created by Dmitry on 06.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxCocoa
import RxFlow

class EventNameViewModel: Stepper, ScreenWithResult {
	let steps = PublishRelay<Step>()
	var onResult: ((String?) -> Void)!
	var eventName: String

	init(initialName: String?) {
		eventName = initialName ?? ""
	}
	
	func submitName() {
		onResult(eventName)
		steps.accept(EventStep.eventNameDidComplete)
	}
	
	func closeScreenWithoutChanges() {
		onResult(nil)
		steps.accept(EventStep.eventNameDidComplete)
	}
}
