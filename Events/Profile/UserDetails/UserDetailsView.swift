//
//  UserDetailsView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 31/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class UserDetailsView: UIView {

  private let contentView = UIView()
  private let headerContainer = UIView()
  let closeButton = UIButton()
  let avatarButton = UIButton()
  let datePicker = UIDatePicker()
  let scrollView = UIScrollView()
  let descriptionTextView = UITextView()
  let submitButton = ButtonScale()
  let genderTextField = TextFieldWithBottomLine()
  let dateTextField = TextFieldWithBottomLine()
  let firstNameSection = UserDetailsSectionView()
  let lastNameSection = UserDetailsSectionView()
  let dateSection = UserDetailsSectionView()
  let genderSection = UserDetailsSectionView()
  let workSection = UserDetailsSectionView()
  let descriptionSection = UserDetailsSectionView()
  
  typealias Delegate = UserDetailsViewDelegate & UIPickerViewDelegate
  
  @objc weak var delegate: Delegate! {
    didSet {
      setupView()
    }
  }
  
  init() {
    super.init(frame: CGRect.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setUserImage(_ image: UIImage) {
    avatarButton.setImage(image, for: .normal)
    avatarButton.imageView
      .foldL(
        none: {},
        some: { v in
          v.layer.cornerRadius = v.bounds.width / 2.0
          v.contentMode = .scaleAspectFill
        }
      )
  }
  
  private func setupView() {
    backgroundColor = .white
    scrollView.showsVerticalScrollIndicator = false

    setipHeader()
    setupAvatarButton()
    setupDateTextField()
    setupGenderTextField()
    setupDescriptionTextView()
    setupSubmitButton()

    sv(scrollView.sv(contentView))
    
    contentView.sv([
      headerContainer,
      firstNameSection,
      lastNameSection,
      avatarButton,
      dateSection,
      genderSection,
      workSection,
      descriptionSection,
      submitButton
      ])

    setupSections()
    setupViewsConstraints()
    setupViewsSizes()
  }
  
  private func setipHeader() {
    let titleLabel = UILabel()
    styleText(
      label: titleLabel,
      text: NSLocalizedString(
        "Tell other users about yourself!",
        comment: "Textfield to write about yourself"
      ),
      size: 26,
      color: .gray900(),
      style: .medium
    )
    titleLabel.style { v in
      v.numberOfLines = 2
      v.textAlignment = .left
    }
    closeButton.style({ v in
      let image = UIImage(
        from: .materialIcon,
        code: "cancel",
        textColor: UIColor.gray900(),
        backgroundColor: .clear,
        size: CGSize(width: 35, height: 35)
      )
      v.setImage(image, for: .normal)
    })
    headerContainer.sv(titleLabel, closeButton)
    titleLabel.left(0).bottom(0).top(0)
    closeButton.right(0)
    titleLabel.Right == closeButton.Left + 10
    closeButton.CenterY == titleLabel.CenterY
  }

  private func setupSections() {
    firstNameSection.setupView(
      with: NSLocalizedString("First name", comment: "User info: First name"),
      childView: TextFieldWithBottomLine()
    )
    lastNameSection.setupView(
      with: NSLocalizedString("Last name", comment: "User info: Last name"),
      childView: TextFieldWithBottomLine()
    )
    dateSection.setupView(
      with: NSLocalizedString("Date of birth", comment: "User info: Date of birth"),
      childView: dateTextField
    )
    genderSection.setupView(
      with: NSLocalizedString("Gender", comment: "User info: Gender"),
      childView: genderTextField
    )
    workSection.setupView(
      with: NSLocalizedString("Work", comment: "User info: Work"),
      childView: TextFieldWithBottomLine()
    )
    descriptionSection.setupView(
      with: NSLocalizedString("Additional information", comment: "User info: Additional info"),
      childView: descriptionTextView
    )
  }
  
  private func setupAvatarButton() {
    avatarButton.style({ v in
      v.layer.cornerRadius = 60
      v.backgroundColor = .blue100()
      let image = UIImage(
        from: .materialIcon,
        code: "photo.camera",
        textColor: .black,
        backgroundColor: .clear,
        size: CGSize(width: 50, height: 50)
      )
      v.setImage(image, for: .normal)
    })
  }
  
  private func setupDateTextField() {
    let toolBar = UIToolbar()
    let tabBarCloseButton = UIBarButtonItem(
      title: NSLocalizedString("Close", comment: "Date picker: close"),
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
      title: NSLocalizedString("Select", comment: "Date picker: select date"),
      style: .done,
      target: delegate,
      action: #selector(delegate.selectDate)
    )
    datePicker.datePickerMode = .date
    toolBar.sizeToFit()
    toolBar.setItems([tabBarCloseButton, spaceButton, tabBarDoneButton], animated: false)
    dateTextField.inputAccessoryView = toolBar
    dateTextField.inputView = datePicker
  }
  
  private func setupGenderTextField() {
    let picker = UIPickerView()
    picker.delegate = delegate
    genderTextField.inputView = picker
  }
  
  private func setupDescriptionTextView() {
    styleText(
      textView: descriptionTextView,
      text: "",
      size: 16,
      color: .gray900(),
      style: .medium
    )
    descriptionTextView.style({ v in
      v.isEditable = true
      v.textContainerInset = UIEdgeInsets(
        top: 0,
        left: 7,
        bottom: 0,
        right: 0
      )
    })
  }
  
  private func setupSubmitButton() {
    styleText(
      button: submitButton,
      text: NSLocalizedString("Save", comment: "User info: Save"),
      size: 20,
      color: .white,
      style: .medium
    )
    submitButton.backgroundColor = UIColor.blue()
  }
  
  private func setupViewsSizes() {
    firstNameSection.height(60)
    submitButton.width(200)
    equal(heights: [firstNameSection, lastNameSection, dateSection, genderSection, workSection])
  }
  
  private func setupViewsConstraints() {
    scrollView.left(0).right(0)
    scrollView.Bottom == safeAreaLayoutGuide.Bottom
    scrollView.Top == safeAreaLayoutGuide.Top
    contentView.fillContainer().centerInContainer()

    headerContainer.left(25).right(15).top(20)
    firstNameSection.left(15)
    firstNameSection.Top == headerContainer.Bottom + 50
    avatarButton.CenterY == lastNameSection.Top
    avatarButton
      .right(15)
      .width(120)
      .heightEqualsWidth()
    [firstNameSection, lastNameSection].forEach { $0.Right == avatarButton.Left - 10 }

    [
      lastNameSection,
      dateSection,
      genderSection,
      workSection,
      descriptionSection
    ]
    .forEach { view in
      let index = contentView.subviews.firstIndex(of: view)
      index.foldL(none: {}, some: { v in
        view.Top == contentView.subviews[v - 1].Bottom + 15
      })
      view.left(15).right(15)
    }
    descriptionSection.Bottom == submitButton.Top - 10
    submitButton.CenterX == contentView.CenterX
    submitButton.bottom(50)
  }
}

@objc protocol UserDetailsViewDelegate: class {
  func endEditing()
  func selectDate()
}
