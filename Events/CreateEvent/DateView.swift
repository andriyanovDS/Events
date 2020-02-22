//
//  DescriptionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import RxSwift

class DateView: UIView, CreateEventView {
  weak var delegate: DateViewDelegate?
  private let dateButton = UIButton()
  private let submitButton = ButtonScale()

  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let titleLabel = UILabel()
  private let dateDescriptionLabel = UILabel()
  private lazy var datePicker = UIDatePicker()
  private lazy var startTimeTextField = UITextField()
  private lazy var durationTextField = UITextField()
  private lazy var startTimeDescriptionLabel = UILabel()
  private lazy var durationDescriptionLabel = UILabel()
  private let disposableBag = DisposeBag()

  init(date: Date) {
    super.init(frame: CGRect.zero)

    datePicker.date = date
    startTimeTextField.text = formattedDatePickerDate()
    setupView()

    keyboardAttach$
      .subscribe(
        onNext: {[weak self] info in
          self?.keyboardHeightDidChange(info: info)
        }
      )
      .disposed(by: disposableBag)
      
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
	
	func setDurationLabelText(_ text: String) {
		durationTextField.text = text
	}

  func setFormattedDate(_ date: String, daysCount: Int) {
    setupDateSection()
    setupDurationSection()
    setupSubmitButton()
    contentView.sv([
      startTimeDescriptionLabel,
      durationDescriptionLabel,
      startTimeTextField,
      durationTextField,
      submitButton
      ])

    setupTimeSectionConstraints()
    setupDurationSectionConstraints()
    setupSubmitButtonConstraints()
  }

  private func formattedDatePickerDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter.string(from: datePicker.date)
  }

  @objc private func onSelectTime() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    startTimeTextField.text = dateFormatter.string(from: datePicker.date)
    endEditing(true)
    delegate?.onSelect(date: datePicker.date)
  }

  @objc private func onDateButtonDidPress() {
    delegate?.onOpenCalendar()
  }

  private func scrollToActiveTextField(keyboardHeight: CGFloat) {
    let activeField = [
      startTimeTextField,
      durationTextField
      ].first { $0.isFirstResponder }

    if let activeField = activeField {
      frame.size.height -= keyboardHeight

      if frame.contains(activeField.frame.origin) {
        let scrollPointY = activeField.frame.origin.y - keyboardHeight
        let scrollPoint = CGPoint(x: 0, y: scrollPointY >= 0 ? scrollPointY : 0)
        scrollView.setContentOffset(scrollPoint, animated: true)
      }
    }
  }

  private func keyboardHeightDidChange(info: KeyboardAttachInfo?) {
    let inset = info.foldL(
      none: { UIEdgeInsets.zero },
      some: { info in UIEdgeInsets(
        top: 0,
        left: 0,
        bottom: info.height,
        right: 0
        )}
    )
    scrollView.contentInset = inset
    scrollView.scrollIndicatorInsets = inset

    if inset.bottom > 0 {
      scrollToActiveTextField(keyboardHeight: inset.bottom)
    }
  }

  private func setupView() {
    backgroundColor = .white
    scrollView.showsVerticalScrollIndicator = false

    styleText(
      label: titleLabel,
      text: NSLocalizedString("Date of event", comment: "Create event: date section title"),
      size: 26,
      color: .gray900(),
      style: .bold
    )
    setupSection(
      label: dateDescriptionLabel,
      labelText: NSLocalizedString(
        "When will the event take place?",
        comment: "Create event: location section description"
      ),
      button: dateButton,
      buttonLabelText: NSLocalizedString("Select date", comment: "Create event: date section select title")
    )
    let dateButtonBackgroundView = UIView()
    dateButton.sv(dateButtonBackgroundView)
    dateButtonBackgroundView.style { v in
      v.fillContainer()
      v.isUserInteractionEnabled = false
      v.isExclusiveTouch = false
      v.hero.id = CALENDAR_SHARED_ID
      v.hero.modifiers = [.duration(0.2)]
    }
    titleLabel.numberOfLines = 2
    dateButton.bringSubviewToFront(dateButton.titleLabel!)
    dateButton.addTarget(self, action: #selector(onDateButtonDidPress), for: .touchUpInside)
    sv(scrollView.sv(
      contentView.sv([
        titleLabel,
        dateDescriptionLabel,
        dateButton
        ])
      )
    )
    setupConstraints()
  }

  private func setupSection(
    label: UILabel,
    labelText: String,
    button: UIButton,
    buttonLabelText: String
    ) {
    styleText(
      label: label,
      text: labelText,
      size: 17,
      color: .gray400(),
      style: .regular
    )
    button.style({ v in
      v.contentHorizontalAlignment = .left
      v.layer.borderColor = UIColor.gray200().cgColor
      v.contentEdgeInsets = UIEdgeInsets(
        top: 15,
        left: 15,
        bottom: 15,
        right: 15
      )
    })
    styleText(
      button: selectButtonStyle(button),
      text: buttonLabelText,
      size: 20,
      color: .gray600(),
      style: .medium
    )
  }

  private func setupSection(
    label: UILabel,
    labelText: String,
    textField: UITextField
    ) {
    styleText(
      label: label,
      text: labelText,
      size: 17,
      color: .gray400(),
      style: .regular
    )
    styleText(
      textField: selectTextFieldStyle(textField),
      text: "",
      size: 20,
      color: .gray600(),
      style: .medium
    )
  }

  private func setupDateSection() {
    let toolBar = UIToolbar()
    let tabBarCloseButton = UIBarButtonItem(
      title: NSLocalizedString("Cancel", comment: "Create event: date section close selection"),
      style: .done,
      target: self,
      action: #selector(endEditing(_:))
    )
    let spaceButton = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil
    )
    let tabBarDoneButton = UIBarButtonItem(
      title: NSLocalizedString("Select date", comment: "Create event: date section select date"),
      style: .done,
      target: self,
      action: #selector(onSelectTime)
    )
    datePicker.datePickerMode = .time
    datePicker.locale = Locale(identifier: "ru_RU")
    toolBar.sizeToFit()
    toolBar.setItems([tabBarCloseButton, spaceButton, tabBarDoneButton], animated: false)
    startTimeTextField.style({ v in
      v.inputAccessoryView = toolBar
      v.inputView = datePicker
    })
    setupSection(
      label: startTimeDescriptionLabel,
      labelText: NSLocalizedString(
        "What time will it start?",
        comment: "Create event: time section select title"
      ),
      textField: startTimeTextField
    )
  }

  private func setupDurationSection() {
    let pickerView = UIPickerView()
    pickerView.delegate = delegate
    pickerView.dataSource = delegate
    durationTextField.inputView = pickerView
    setupSection(
      label: durationDescriptionLabel,
      labelText: NSLocalizedString(
        "How long will it last?",
        comment: "Create event: time section select duration"
      ),
      textField: durationTextField
    )
  }

  private func setupSubmitButton() {
    styleText(
      button: submitButton,
      text: NSLocalizedString("Next step", comment: "Create event: next step"),
      size: 20,
      color: .white,
      style: .medium
    )
    submitButton.backgroundColor = UIColor.blue()
    guard let delegate = self.delegate else { return }
    submitButton.addTarget(delegate, action: #selector(delegate.openNextScreen), for: .touchUpInside)
  }

  private func setupConstraints() {
    scrollView.left(20).right(20)
    scrollView.Top == safeAreaLayoutGuide.Top
    scrollView.Bottom == safeAreaLayoutGuide.Bottom
    contentView.fillContainer().centerInContainer()

    titleLabel
      .top(20%)
      .left(0)
      .right(0)

    align(vertically: [titleLabel, dateDescriptionLabel, dateButton])

    layout(
      |-titleLabel-|,
      8,
      |-dateDescriptionLabel-|,
      35,
      |-dateButton-|
    )
  }

  private func setupTimeSectionConstraints() {
    align(vertically: [titleLabel, startTimeDescriptionLabel, startTimeTextField])
    startTimeDescriptionLabel.Top == dateButton.Bottom + 30
    layout(
      |-startTimeDescriptionLabel-|,
      35,
      |-startTimeTextField.height(50)-|
    )
  }

  private func setupDurationSectionConstraints() {
    align(vertically: [titleLabel, durationDescriptionLabel, durationTextField])
    durationDescriptionLabel.Top == startTimeTextField.Bottom + 30
    equal(heights: [startTimeTextField, durationTextField])
    layout(
      |-durationDescriptionLabel-|,
      35,
      |-durationTextField-|
    )
  }

  private func setupSubmitButtonConstraints() {
    submitButton.Bottom == contentView.Bottom - 50
    submitButton.width(200).centerHorizontally()
  }
}

protocol DateViewDelegate: CreateEventViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  func onOpenCalendar()
  func onSelect(date: Date)
  func onSelect(duration: EventDurationRange)
}
