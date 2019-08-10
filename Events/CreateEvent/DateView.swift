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

  init() {
    super.init(frame: CGRect.zero)
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
      text: "Время проведения",
      size: 26,
      color: .gray900(),
      style: .bold
    )
    setupSection(
      label: dateDescriptionLabel,
      labelText: "Когда будет проходить мероприятие?",
      button: dateButton,
      buttonLabelText: "Выберите дату"
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
    textField: UITextField,
    textFieldPlaceholder: String
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
      styleText(textField: v, text: "10:00", size: 18, color: .gray600(), style: .medium)
    })
  }

  private func setupDateSection() {
    let toolBar = UIToolbar()
    let tabBarCloseButton = UIBarButtonItem(
      title: "Закрыть",
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
      title: "Выбрать",
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
      labelText: "Во сколько оно начнется?",
      textField: startTimeTextField,
      textFieldPlaceholder: "10:00"
    )
  }

  private func setupDurationSection() {
    let pickerView = UIPickerView()
    pickerView.delegate = delegate
    durationTextField.inputView = pickerView
    setupSection(
      label: durationDescriptionLabel,
      labelText: "Сколько оно будет длиться?",
      textField: durationTextField,
      textFieldPlaceholder: "1 час"
    )
  }

  private func setupSubmitButton() {
    styleText(
      button: submitButton,
      text: "Далее",
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
