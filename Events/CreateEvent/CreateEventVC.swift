//
//  CreateEventVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import RxSwift
import SwiftIconFont

class CreateEventViewController: UIViewControllerWithActivityIndicator, ViewModelBased {
	var viewModel: CreateEventViewModel! {
		didSet {
			viewModel.delegate = self
		}
	}
  private let disposeBag = DisposeBag()
  private var initialScreenViewController: LocationViewController?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .background
  }
}

extension CreateEventViewController: CreateEventViewModelDelegate {
	func showProgress() {
		showActivityIndicator(for: navigationController?.view)
	}
	
	func hideProgress() {
		removeActivityIndicator()
	}
}

@objc protocol CreateEventViewDelegate: class {
  func openNextScreen()
}

protocol CreateEventView: UIView {
  associatedtype Delegate = CreateEventViewDelegate
  var delegate: Delegate { get set }
}

protocol ViewWithKeyboard {
  func keyboardHeightDidChange(_: KeyboardAttachInfo?)
}
