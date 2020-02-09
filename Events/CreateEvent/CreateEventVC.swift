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

@objcMembers class CreateEventViewController: KeyboardAttachViewController, ViewModelBased,
  CreateEventViewModelDelegate,
  DateViewDelegate {
  var locationView: LocationView?
  var dateView: DateView?
  var categoriesView: CategoriesView?
  var descriptionView: DescriptionView?
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
  }
  
  private func setupView() {
    viewModel.delegate = self
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
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateView = DateView(
      startTime: dateFormatter.string(from: viewModel.dates[0]),
      duration: toLabel(duration: viewModel.duration!)
    )
    dateView?.delegate = self
    dateView?.datePicker.date = viewModel.dates[0]
    dateView?.dateButton.addTarget(self, action: #selector(selectDate), for: .touchUpInside)
    dateView?.submitButton.addTarget(self, action: #selector(setupCategoriesView), for: .touchUpInside)
    view = dateView
    locationView = nil
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
    descriptionView = DescriptionView()
    view = descriptionView
    categoriesView = nil
    descriptionView?.textView.delegate = self
    setupOpenImagePickerButton()

    let popup = HintPopup(
      title: NSLocalizedString("Format you text", comment: "Format text hint: title"),
      description: NSLocalizedString(
        "Format you text using special symbols to make it more detailed",
        comment: "Format text hint: description"
      ),
      link: NSLocalizedString("Press to get more info", comment: "Format text hint: open hint button label"),
      image: UIImage(named: "textFormatting")!
    )
    viewModel.openHintPopup(popup: popup)
  }

  func onChangeLocationName(_ name: String) {
    locationView?.locationButton.setTitle(name, for: .normal)
  }

  func onDatesDidSelected(formattedDate: String, daysCount: Int) {
    dateView?.setFormattedDate(formattedDate, daysCount: daysCount)
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
      navigationItem.rightBarButtonItem = nil
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

  private func setupOpenImagePickerButton() {
    let openImagePickerButton = UIButtonScaleOnPress()
    openImagePickerButton.setImage(
      UIImage(named: "AddImage"),
      for: .normal
    )
    openImagePickerButton.imageView?.style { v in
      v.clipsToBounds = true
      v.contentMode = .scaleAspectFit
    }

    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: openImagePickerButton)
    openImagePickerButton.width(35).height(35)
    openImagePickerButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
  }

  private func isDescriptionValid(_ textView: UITextView) -> Bool {
    return textView.text.count > 0
  }

  @objc private func onPressCategoryButton(_ button: CategoryButton) {
    viewModel.onSelectCategory(id: button.category)
    setupDescriptionView()
  }

  @objc private func openImagePicker() {
    viewModel.openImagePicker(onResult: { assets in
      self.descriptionView?.selectImagesView.handleImagePickerResult(assets: assets)
    })
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
  let formatString = NSLocalizedString("Event duration hours", comment: "Event duration hours plural")

  let minRangeLabelFnOption = duration.min
    .map { durationRangeLabel(formatString: formatString)($0) }
    .orElse({ (max: Int) in String.localizedStringWithFormat(formatString, max) })

  return duration.max
    .ap(minRangeLabelFnOption)
    .getOrElseL({ duration.min
      .map { min in
        "\(NSLocalizedString("More than", comment: "Event duration hours"))"
        + " \(String.localizedStringWithFormat(formatString, min))"
      }
      .getOrElse(result: "")
    })
}

extension CreateEventViewController: UITextViewDelegate {

  func textViewDidChange(_ textView: UITextView) {
    guard let descriptionView = descriptionView else {
      return
    }
    descriptionView.submitButton.isEnabled = textView.text.count > 0
  }
}

func durationRangeLabel(formatString: String) -> (Int) -> (Int) -> String {
  return { (min: Int) in
    return { (max: Int) in "\(min) - \(String.localizedStringWithFormat(formatString, max))" }
  }
}
