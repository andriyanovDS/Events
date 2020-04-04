//
//  StartViewController.swift
//  Events
//
//  Created by Dmitry on 15.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift

class StartViewController: UIViewController, ViewModelBased, ScreenWithResult, StartViewModelDelegate {
	var viewModel: StartViewModel! {
		didSet {
			viewModel.delegate = self
		}
	}
	var onBackAction: (() -> Void)!
	var onResult: ((StartViewResult) -> Void)!
	private var startView: StartView?
	private var disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		
		keyboardAttachWithDebounce$.subscribe(
		 onNext: {[weak self] info in
			 self?.startView?.keyboardHeightDidChange(info)
			}
		)
		.disposed(by: disposeBag)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if isMovingFromParent {
      onBackAction()
    }
  }
	
	private func setupView() {
		let startView = StartView()
		
		startView.submitButton.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
		startView.titleTextField.addTarget(self, action: #selector(titleDidChanged(_:)), for: .editingChanged)
		startView.publicSwitch.addTarget(self, action: #selector(onPublicStateChange(_:)), for: .valueChanged)
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onPressView))
    tapRecognizer.cancelsTouchesInView = false
		startView.addGestureRecognizer(tapRecognizer)
		
		view = startView
		self.startView = startView
	}
	
	@objc private func onPressView() {
		startView?.endEditing(true)
	}
	
	@objc func titleDidChanged(_ textField: UITextField) {
		viewModel.eventName = textField.text
		startView?.submitButton.isEnabled = textField.text
			.map { $0.count > 0 }
			.getOrElse(result: false)
	}
	
	@objc private func onPublicStateChange(_ switchState: UISwitch) {
		viewModel.isEventPiblic = switchState.isOn == false
		startView?.isPublic = viewModel.isEventPiblic
	}
	
	@objc private func onSubmit() {
		viewModel.onNextScreen()
	}
}
