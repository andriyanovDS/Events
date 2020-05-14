//
//  DateViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 07/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class DateViewController: UIViewController, ViewModelBased {
  var viewModel: DateViewModel! {
    didSet {
      viewModel.delegate = self
    }
  }
  private var dateView: DateView?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  private func setupView() {
    let dateView = DateView(date: viewModel.dates[0])
     dateView.delegate = self
     if let duration = viewModel.duration {
       dateView.setDurationLabelText(duration.localizedLabel)
     }
    view = dateView
    self.dateView = dateView
  }
}

extension DateViewController: DateViewDelegate {
  func openNextScreen() {
    viewModel.onClose()
  }

  func onSelect(duration: EventDurationRange) {
    viewModel.duration = duration
  }

  func onSelect(date: Date) {
    viewModel.onSelect(date: date)
  }

  func onOpenCalendar() {
    viewModel.openCalendar()
  }

  private func pickerRowValueToDurationRange(_ row: Int) -> EventDurationRange? {
    return viewModel.durations[row]
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    onSelect(duration: viewModel.durations[row])
    dateView?.setDurationLabelText(viewModel.durations[row].localizedLabel)
    view.endEditing(true)
  }

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return viewModel.durations[row].localizedLabel
  }

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return viewModel.durations.count
  }
}

extension DateViewController: DateViewModelDelegate {
  func onDatesDidSelected(formattedDate: String, daysCount: Int) {
    dateView?.setFormattedDate(formattedDate, daysCount: daysCount)
  }
}
