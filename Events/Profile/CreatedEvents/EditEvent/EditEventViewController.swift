//
//  EditEventViewController.swift
//  Events
//
//  Created by Dmitry on 03.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift
import Hero

class EditEventViewController: UIViewController, ViewModelBased {
	var viewModel: EditEventViewModel!
	private let disposeBag = DisposeBag()
	private var editEventView: EditEventView?
  private var resignedView: UIView?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupNavigationBar()
		setupView()
		
		keyboardAttach$
			.subscribe(onNext: {[weak self] info in
				self?.editEventView?.onKeyboardHeightDidChange(info: info)
			})
			.disposed(by: disposeBag)
	}
	
	private func setupView() {
		let event = viewModel.event
		
		let accessButton = EditButton(type: .access(isPrivate: event.isPublic))
		let dateButton = EditButton(type: .date(dateLabelText: event.dateLabelText))
    dateButton.hero.id = calendarSharedElementId
		let categoryButton = EditButton(type: .category(categoryId: event.categories.first!))
		let editButtons = [accessButton, dateButton, categoryButton]

    let locationButton = UIButtonScaleOnPress()
    let timeButton = UIButtonScaleOnPress()
    let footerButtons = [
      EditEventFooterButton(
        icon: Icon(material: "location.on", sfSymbol: "location"),
        button: locationButton
      ),
      EditEventFooterButton(
        icon: Icon(material: "schedule", sfSymbol: "clock"),
        button: timeButton
      )
    ]

		let view = EditEventView(editButtons: editButtons, footerButtons: footerButtons)
		view.titleButton.setTitle(viewModel.event.name, for: .normal)
		if let mainDescription = viewModel.event.description.first {
			view.mainDescriptionTextView.text = mainDescription.text
		}
		self.view = view
		editEventView = view
		
		view.titleButton.rx.tap
			.subscribe(onNext: {[unowned self] _ in
        self.viewModel.openEventNameModal()
					.then { view.titleButton.setTitle($0, for: .normal) }
      })
			.disposed(by: disposeBag)
		view.mainDescriptionTextView.rx.text.orEmpty
			.subscribe(onNext: {[unowned self] text in
				self.viewModel.event.description[0].text = text
			})
			.disposed(by: disposeBag)
		
		accessButton.rx.tap
			.subscribe(onNext: {[unowned self] _ in
        self.viewModel.toggleEventAccess()
        accessButton.type = .access(isPrivate: self.viewModel.event.isPublic)
      })
			.disposed(by: disposeBag)
		dateButton.rx.tap
			.subscribe(onNext: {[unowned self] _ in
        self.viewModel.openCalendar()
          .then { dateButton.type = .date(dateLabelText: $0) }
      })
			.disposed(by: disposeBag)
		categoryButton.rx.tap
      .subscribe(onNext: {[unowned self] _ in
        self.categoryButtonDidPress(categoryButton)
      })
			.disposed(by: disposeBag)

    locationButton.rx.tap
      .subscribe(onNext: {[weak self] in self?.viewModel.openLocationSearch() })
      .disposed(by: disposeBag)
		
		timeButton.rx.tap
			.subscribe(onNext: {[weak self] in
				guard let self = self else { return }
				self.viewModel.openDatePicker()
					.then { dateButton.type = .date(dateLabelText: $0) }
			})
			.disposed(by: disposeBag)
	}

  private func categoryButtonDidPress(_ sender: EditButton) {
    guard let view = editEventView else { return }
     if view.mainDescriptionTextView.isFirstResponder {
			 resignedView = view.mainDescriptionTextView
		 }
    resignedView?.resignFirstResponder()
    viewModel.openCategoryListModal()
      .then {[weak self] result in
        self?.resignedView?.becomeFirstResponder()
        sender.type = .category(categoryId: result)
      }
  }
	
	private func setupNavigationBar() {
		title = NSLocalizedString(
			"Edit event",
			comment: "Edit event: title"
		)
		guard let navigationBar = navigationController?.navigationBar else {
			return
		}
		navigationBar.backgroundColor = .background
		navigationBar.isOpaque = true
		navigationBar.titleTextAttributes = [
			NSAttributedString.Key.font: FontStyle.bold.font(size: 22),
			NSAttributedString.Key.foregroundColor: UIColor.fontLabel
		]
		let backButton = UIButtonScaleOnPress()
    backButton.setIcon(
      Icon(material: "cancel", sfSymbol: "xmark.circle.fill"),
      size: 30,
      color: .grayButtonDarkFont
    )
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
		backButton.width(44).height(44)
		backButton.rx.tap
			.subscribe(onNext: {[weak self] _ in  self?.viewModel.closeScreen()})
			.disposed(by: disposeBag)
		
		let sendButton = SendButtonView(cornerRadius: 15)
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
		sendButton.width(30).height(30)
		sendButton.rx.tap
			.subscribe(onNext: {[weak self] _ in self?.viewModel.editEvent()})
			.disposed(by: disposeBag)
	}
}
