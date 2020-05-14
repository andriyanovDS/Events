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

class EventNameViewModel: Stepper, ResultProvider {
	let steps = PublishRelay<Step>()
  let onResult: ResultHandler<String?>
	var eventName: String

  init(eventName: String = "", onResult: @escaping ResultHandler<String?>) {
    self.eventName = eventName
    self.onResult = onResult
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
