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

class StartViewModel: Stepper, ResultProvider {
	let steps = PublishRelay<Step>()
	let onResult: ResultHandler<StartViewResult>
	var isEventPiblic: Bool = true
	var eventName: String?

  init(onResult: @escaping ResultHandler<StartViewResult>) {
    self.onResult = onResult
  }
	
	func onNextScreen() {
		guard let name = eventName else { return }
		onResult(StartViewResult(
			name: name,
			isPublic: isEventPiblic
		))
	}
}

struct StartViewResult {
	let name: String
	let isPublic: Bool
}
