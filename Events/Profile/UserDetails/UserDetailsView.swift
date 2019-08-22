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
  
  private let titleLabel = UILabel()
  let closeButton = UIButton()
  let avatarButton = UIButton()
  let datePicker = UIDatePicker()
  let scrollView = UIScrollView()
  let descriptionTextView = UITextView()
  let submitButton = ButtonWithBorder()
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
  
  private func setupView() {
    backgroundColor = .white
    
    let contentView = UIView()
    scrollView.showsVerticalScrollIndicator = false
    
    sv(scrollView.sv(contentView))
    scrollView
      .left(15)
      .right(15)
    
    scrollView.Bottom == safeAreaLayoutGuide.Bottom
    scrollView.Top == safeAreaLayoutGuide.Top
    contentView.fillContainer().centerInContainer()
    
    setipTitle()
    setupCloseButton()
    setupAvatarButton()
    setupDateTextField()
    setupGenderTextField()
    setupDescriptionTextView()
    setupSubmitButton()
    
    contentView.sv([
      titleLabel,
      closeButton,
      firstNameSection,
      lastNameSection,
      avatarButton,
      dateSection,
      genderSection,
      workSection,
      descriptionSection,
      submitButton
      ])
    
    setupViewsSizes()
    setupViewsConstraints(contentView: contentView)
    setupSections()
  }
  
  private func setipTitle() {
    titleLabel.style({ v in
      v.text = "Расскажи другим пользователям о себе!"
      v.textColor = UIColor.gray900()
      v.font = UIFont(name: "CeraPro-Medium", size: 26)
      v.numberOfLines = 2
      v.textAlignment = .left
    })
  }
  
  func setupCloseButton() {
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
  }
  
  private func setupSections() {
    firstNameSection.setupView(with: "Имя", childView: TextFieldWithBottomLine())
    lastNameSection.setupView(with: "Фамилия", childView: TextFieldWithBottomLine())
    dateSection.setupView(with: "Дата рождения", childView: dateTextField)
    genderSection.setupView(with: "Пол", childView: genderTextField)
    workSection.setupView(with: "Работа", childView: TextFieldWithBottomLine())
    descriptionSection.setupView(with: "Дополнительная информация", childView: descriptionTextView)
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
    descriptionTextView.style({ v in
      v.isEditable = true
      v.textContainerInset = UIEdgeInsets(
        top: 0,
        left: 7,
        bottom: 0,
        right: 0
      )
      v.font = UIFont(name: "CeraPro-Medium", size: 16)
      v.textColor = UIColor.gray900()
    })
  }
  
  private func setupSubmitButton() {
    submitButton.style({ v in
      v.setTitle("Сохранить", for: .normal)
      v.layer.borderColor = UIColor.blue().cgColor
      v.setTitleColor(UIColor.blue(), for: .normal)
      v.contentEdgeInsets = UIEdgeInsets(
        top: 10,
        left: 0,
        bottom: 10,
        right: 0
      )
      v.titleLabel?.font = UIFont(name: "CeraPro-Medium", size: 20)
    })
  }
  
  private func setupViewsSizes() {
    firstNameSection.width(180).height(60)
    avatarButton
      .width(120)
      .heightEqualsWidth()
    descriptionSection.height(120)
    submitButton.width(200)
    equal(sizes: [firstNameSection, lastNameSection])
    equal(heights: [firstNameSection, dateSection, genderSection, workSection])
  }
  
  private func setupViewsConstraints(contentView: UIView) {
    titleLabel.top(20)
    align(tops: [titleLabel, closeButton])
    
    |-titleLabel-10-closeButton.right(0)|
    
    firstNameSection.Top == titleLabel.Bottom + 50
    lastNameSection.Top == firstNameSection.Bottom + 15
    avatarButton.CenterY == lastNameSection.Top
    avatarButton.right(0)
    dateSection.Top == lastNameSection.Bottom + 15
    align(lefts: [
      firstNameSection,
      lastNameSection,
      dateSection,
      genderSection,
      workSection,
      descriptionSection
      ])
    
    layout(
      |-dateSection-|,
      15,
      |-genderSection-|,
      15,
      |-workSection-|,
      15,
      |-descriptionSection-|
    )
    submitButton.centerHorizontally()
    submitButton.Top == descriptionSection.Bottom + 30
    submitButton.Bottom == contentView.Bottom - 20
  }
}

@objc protocol UserDetailsViewDelegate: class {
  func endEditing()
  func selectDate()
}
