//
//  EditEventView.swift
//  Events
//
//  Created by Dmitry on 03.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EditEventView: UIView {
	let titleButton = UIButtonScaleOnPress()
	let titleTextView = UITextView()
	let mainDescriptionTextView = UITextView()
	private let contentView = UIView()
	private let editButtonsStackView = UIStackView()
  private let descripitionScrollView = UIScrollView()
  private let editButtonsScrollView = UIScrollView()
  private let footerView: EditEventFooterView
	private let editButtons: [EditButton]
	
  init(editButtons: [EditButton], footerButtons: [EditEventFooterButton]) {
		self.editButtons = editButtons
    footerView = EditEventFooterView(buttons: footerButtons)

		super.init(frame: CGRect.zero)
		setupView()
		setupConstraints()
	}
		
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func onKeyboardHeightDidChange(info: KeyboardAttachInfo?) {
    let durationOption = info?.duration
    let duration = durationOption
      .map { max(0.2, $0) }
      .getOrElse(result: 0.2)
		UIView.animate(withDuration: duration, animations: {
      let bottomConstraint = info
				.map(\.height)
        .map { $0 - self.safeAreaInsets.bottom }
        .getOrElse(result: 0)
      self.contentView.bottomConstraint?.constant = -bottomConstraint
      self.layoutIfNeeded()
    })
	}
		
	private func setupView() {
		backgroundColor = .white
		styleText(
			button: titleButton,
			text: NSLocalizedString("Enter title..", comment: "Edit event: title placeholder"),
			size: 20,
			color: .black,
			style: .bold
		)
		titleButton.layer.cornerRadius = 15
    titleButton.backgroundColor = .gray100()
		titleButton.titleEdgeInsets = UIEdgeInsets(
			top: 0,
			left: 10,
			bottom: 0,
			right: 10
		)
		styleText(
			textView: mainDescriptionTextView,
			text: "",
			size: 16,
			color: .black,
			style: .medium
		)
		mainDescriptionTextView.contentInset = UIEdgeInsets(
			top: 8,
			left: 6,
			bottom: 50,
			right: 6
		)
    mainDescriptionTextView.isScrollEnabled = false

    descripitionScrollView.isDirectionalLockEnabled = true
    editButtonsScrollView.showsHorizontalScrollIndicator = false
		editButtonsStackView.axis = .horizontal
		editButtonsStackView.spacing = 10
		editButtonsStackView.distribution = .equalSpacing
		editButtons.forEach { editButtonsStackView.addArrangedSubview($0) }
    editButtonsScrollView.sv(editButtonsStackView)
    descripitionScrollView.sv(mainDescriptionTextView, editButtonsScrollView)
    editButtonsScrollView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

		sv(contentView.sv([
			titleButton,
			descripitionScrollView,
      footerView
		]))
	}
	
	private func setupConstraints() {
		contentView.Top == safeAreaLayoutGuide.Top
		contentView.Bottom == safeAreaLayoutGuide.Bottom
		contentView.left(0).right(0)
		titleButton.top(10).left(10).right(10).height(40)
		descripitionScrollView.Top == titleButton.Bottom + 15
    descripitionScrollView.left(0).right(0).bottom(40)
    mainDescriptionTextView.Width == descripitionScrollView.Width - 20
    mainDescriptionTextView.top(10).right(10).left(10)
    editButtonsScrollView.left(0).right(0).bottom(15)
    mainDescriptionTextView.Bottom == editButtonsScrollView.Top - 10
    editButtonsStackView.top(0).bottom(0).left(0).right(0)
    editButtonsStackView.Height == editButtonsScrollView.Height
    footerView.left(0).right(0).bottom(0).height(40)
	}
}
