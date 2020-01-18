//
//  DescriptionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class DateView: UIView {
  weak var delegate: DateViewDelegate!
  let dateButton = ButtonWithBorder()
  var submitButton = ButtonWithBorder()
  lazy var datePicker = UIDatePicker()
  lazy var startTimeTextField = UITextField()
  lazy var durationTextField = UITextField()
  let scrollView = UIScrollView()
  private let contentView = UIView()
  private let titleLabel = UILabel()
  private let dateDescriptionLabel = UILabel()
  private lazy var startTimeDescriptionLabel = UILabel()
  private lazy var durationDescriptionLabel = UILabel()

  init(startTime: String, duration: String) {
    super.init(frame: CGRect.zero)

    startTimeTextField.text = startTime
    durationTextField.text = duration

    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setFormattedDate(_ date: String, daysCount: Int) {
    dateButton.setTitle(date, for: .normal)
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
      button: button,
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
    textField.style({ v in
      v.layer.borderWidth = 1
      v.layer.borderColor = UIColor.gray200().cgColor
      v.setupLeftView(width: 15)
      v.layer.cornerRadius = 4
      styleText(textField: v, text: "", size: 18, color: .gray600(), style: .medium)
    })
  }

  private func setupDateSection() {
    let toolBar = UIToolbar()
    let tabBarCloseButton = UIBarButtonItem(
      title: NSLocalizedString("Cancel", comment: "Create event: date section close selection"),
      style: .done,
      target: delegate,
      action: #selector(delegate.endEditing)
    )
    let spaceButton = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil
    )
    let tabBarDoneButton = UIBarButtonItem(
      title: NSLocalizedString("Select date", comment: "Create event: date section select date"),
      style: .done,
      target: delegate,
      action: #selector(delegate.onSelectTime)
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
      text: NSLocalizedString("Next step",comment: "Create event: next step"),
      size: 20,
      color: .blue(),
      style: .medium
    )
    submitButton.contentEdgeInsets = UIEdgeInsets(
      top: 7,
      left: 0,
      bottom: 7,
      right: 0
    )
    submitButton.layer.borderColor = UIColor.blue().cgColor
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

@objc protocol DateViewDelegate: class, UIPickerViewDelegate {
  func endEditing()
  func onSelectTime()
}
