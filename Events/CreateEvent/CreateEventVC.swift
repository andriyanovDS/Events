//
//  CreateEventVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import SwiftIconFont

@objcMembers class CreateEventViewController: KeyboardAttachViewController,
  CreateEventViewModelDelegate,
  DateViewDelegate {
  var locationView: LocationView?
  var dateView: DateView?
  var categoriesView: CategoriesView?
  var descriptionView: DescriptionView?
  var coordinator: CreateEventCoordinator?
  var viewModel: CreateEventViewModel!
  
  override var keyboardAttachInfo: KeyboardAttachInfo? {
    didSet {
      onKeyboardHeightDidChange()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupView()
    showActivityIndicator(for: nil)
    viewModel = CreateEventViewModel(delegate: self)
    viewModel.coordinator = coordinator
  }
  
  private func setupView() {
    view.backgroundColor = .white
  }
  
  func setupLocationView(locationName: String) {
    removeActivityIndicator()
    locationView = LocationView(locationName: locationName)
    locationView?.locationButton.addTarget(self, action: #selector(onChangeLocation), for: .touchUpInside)
    locationView?.submitButton.addTarget(self, action: #selector(setupDateView), for: .touchUpInside)
    view = locationView
  }
  
  func setupDateView() {
    setupDescriptionView()
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "HH:mm"
//    dateView = DateView(
//      startTime: dateFormatter.string(from: viewModel.dates[0]),
//      duration: toLabel(duration: viewModel.duration!)
//    )
//    dateView?.delegate = self
//    dateView?.datePicker.date = viewModel.dates[0]
//    dateView?.dateButton.addTarget(self, action: #selector(selectDate), for: .touchUpInside)
//    dateView?.submitButton.addTarget(self, action: #selector(setupCategoriesView), for: .touchUpInside)
//    view = dateView
//    locationView = nil
  }

  func setupCategoriesView() {
    categoriesView = CategoriesView()
    categoriesView?.categoryButtons.forEach { $0.addTarget(
      self,
      action: #selector(onPressCategoryButton(_:)),
      for: .touchUpInside
    )}
    view = categoriesView
    dateView = nil
  }

  func setupDescriptionView() {
    descriptionView = DescriptionView(allowMultipleImages: true)
    view = descriptionView
    categoriesView = nil
    descriptionView?.textView.delegate = self
    descriptionView?.selectImageButton.addTarget(
      self,
      action: #selector(onSelectImages),
      for: .touchUpInside
    )

    let popup = HintPopup(
      title: "Оформите свой текст",
      description: "Форматируйте свой текст, используя специальные символы, чтобы сделать его более подробным и ясным.",
      link: "Нажмите, чтобы узнать больше",
      image: UIImage(named: "textFormatting")!
    )
//    viewModel.openHintPopup(popup: popup)
  }

  private func isDescriptionValid(_ textView: UITextView) -> Bool {
    return textView.text.count > 0
  }
  
  func onChangeLocationName(_ name: String) {
    locationView?.locationButton.setTitle(name, for: .normal)
  }
  
  func onDatesDidSelected(formattedDate: String, daysCount: Int) {
    dateView?.setFormattedDate(formattedDate, daysCount: daysCount)
  }

  @objc private func onPressCategoryButton(_ button: CategoryButton) {
    viewModel.onSelectCategory(id: button.category)
    setupDescriptionView()
  }

  @objc private func onSelectImages() {
    viewModel.onSelectImages()
  }
  
  private func setupNavigationBar() {
    navigationController?.navigationBar.barTintColor = UIColor.white
    let backButtonImage = UIImage(
      from: .ionicon,
      code: "ios-arrow-back",
      textColor: .black,
      backgroundColor: .clear,
      size: CGSize(width: 40, height: 40)
    )
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: backButtonImage,
      style: .plain,
      target: self,
      action: #selector(onBackAction)
    )
    navigationController?.isNavigationBarHidden = false
  }
  
  func onBackAction() {
    if dateView != nil, let geocode = viewModel.geocode {
      setupLocationView(locationName: geocode.fullLocationName())
      dateView = nil
      return
    }
    if categoriesView != nil {
      setupDateView()
      categoriesView = nil
      return
    }
    if descriptionView != nil {
      setupCategoriesView()
      descriptionView = nil
      return
    }
    viewModel.closeScreen()
  }
  
  func onChangeLocation() {
    viewModel.openLocationSearchBar()
  }
  
  func selectDate() {
    viewModel.openCalendar()
  }
  
  func endEditing() {
    view.endEditing(true)
  }
  
  func onSelectTime() {
    guard let dateView = dateView else {
      return
    }
    viewModel.onSelectStartTime(date: dateView.datePicker.date)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateView.startTimeTextField.text = dateFormatter.string(from: dateView.datePicker.date)
    endEditing()
  }
  
  private func scrollToActiveTextField(keyboardHeight: CGFloat) {
    guard let view = dateView else {
      return
    }
    let activeField = [
      view.startTimeTextField,
      view.durationTextField
      ].first { $0.isFirstResponder }
    
    if let activeField = activeField {
      var viewFrame = view.frame
      viewFrame.size.height -= keyboardHeight
      
      if viewFrame.contains(activeField.frame.origin) {
        let scrollPointY = activeField.frame.origin.y - keyboardHeight
        let scrollPoint = CGPoint(x: 0, y: scrollPointY >= 0 ? scrollPointY : 0)
        view.scrollView.setContentOffset(scrollPoint, animated: true)
      }
    }
  }
  
  private func onKeyboardHeightDidChange() {
    let inset = keyboardAttachInfo.foldL(
      none: { UIEdgeInsets.zero },
      some: { info in UIEdgeInsets(
        top: 0,
        left: 0,
        bottom: info.height,
        right: 0
        )}
    )
    dateView?.scrollView.contentInset = inset
    dateView?.scrollView.scrollIndicatorInsets = inset
    
    if inset.bottom > 0 {
      scrollToActiveTextField(keyboardHeight: inset.bottom)
    }
  }
}

extension CreateEventViewController: UIPickerViewDataSource {
  
  private func pickerRowValueToDurationRange(_ row: Int) -> EventDurationRange? {
    return viewModel.durations[row]
  }
  
  private func pickerRowValueToDurationLabel(_ row: Int) -> String? {
    let duration = viewModel.durations[row]
    return duration.map { v in toLabel(duration: v) }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return viewModel.durations.count
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    viewModel.onSelectEventDuration(row)
    dateView?.durationTextField.text = pickerRowValueToDurationLabel(row)
    view.endEditing(true)
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerRowValueToDurationLabel(row)
  }
}

private func toLabel(duration: EventDurationRange) -> String {
  return duration.min
    .chain({ min in duration.max.foldL(
      none: { "Более \(min) часов" },
      some: { max in "\(min) - \(max) часов" }
      )})
    .alt({ duration.max.map { max in "\(max) \(max > 1 ? "часов" : "час")" } })
    .getOrElse(result: "")
}

extension CreateEventViewController: UITextViewDelegate {

  func textViewDidChange(_ textView: UITextView) {
    guard let descriptionView = descriptionView else {
      return
    }
    descriptionView.submitButton.isEnabled = textView.text.count > 0
  }
}
