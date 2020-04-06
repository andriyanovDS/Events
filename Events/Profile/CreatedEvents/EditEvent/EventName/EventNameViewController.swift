//
//  EventNameViewController.swift
//  Events
//
//  Created by Dmitry on 06.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift

class EventNameViewController: UIViewController, ViewModelBased {
	var viewModel: EventNameViewModel!
	private var eventNameView: EventNameView?
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		eventNameView?.nameTextView.becomeFirstResponder()
	}
	
	private func setupView() {
		let view = EventNameView()
		view.nameTextView.text = viewModel.eventName
		
		keyboardAttach$
			.subscribe(onNext: { view.keyboardHeightDidChange($0) })
			.disposed(by: disposeBag)
		
		view.closeButton.rx.tap
			.subscribe(onNext: {[unowned self] in
				self.viewModel.closeScreenWithoutChanges()
			})
			.disposed(by: disposeBag)
		
		view.submitButton.rx.tap
			.subscribe(onNext: {[unowned self] in self.viewModel.submitName() })
			.disposed(by: disposeBag)
		
		view.nameTextView.rx.text.orEmpty
			.subscribe(onNext: {[unowned self] text in
				view.submitButton.isEnabled = !text.isEmpty
				self.viewModel.eventName = text
			})
			.disposed(by: disposeBag)
			
		self.view = view
		eventNameView = view
	}
}
