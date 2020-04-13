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
  let datePicker = UIDatePicker()
  let scrollView = UIScrollView()
  let submitButton = ButtonScale()
	let genderPicker = UIPickerView()
	let firstNameTextField = TextFieldWithBottomLine()
	let lastNameTextField = TextFieldWithBottomLine()
	let dateTextField = TextFieldWithBottomLine()
	let genderTextField = TextFieldWithBottomLine()
	let workTextField = TextFieldWithBottomLine()
	let	descriptionTextView = UITextView()
	let avatarImageView: AvatarImageView
	private let nameSectionStackView = UIStackView()
	private let otherSectionsStackView = UIStackView()
	
	struct Constants {
		static let avatarImageSize = CGSize(
			width: 120,
			height: 120
		)
	}
	
	init(user: User) {
		let defaultAvatarImage = UIImage(
			from: .materialIcon,
			code: "photo.camera",
			textColor: .fontLabel,
			backgroundColor: .clear,
			size: CGSize(width: 50, height: 50)
		)
		avatarImageView = AvatarImageView(defaultImage: defaultAvatarImage)
		
		super.init(frame: CGRect.zero)
		setupView(user: user)
		
		if let date = user.dateOfBirth {
			datePicker.date = date
		}
		if let userAvatar = user.avatar {
			avatarImageView.fromExternalUrl(
				userAvatar,
				withResizeTo: Constants.avatarImageSize,
				loadOn: .global(qos: .background),
				transitionConfig: UIImageView.TransitionConfig(duration: 0.3)
			)
		}
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setUserImage(_ image: UIImage) {
		let newImage = UIImage.resize(image, expectedSize: Constants.avatarImageSize)
		avatarImageView.image = newImage
  }
	
	private func setupSections(user: User) -> [UserDetailsSectionView] {
		let firstNameSection = UserDetailsSectionView(
			labelText: NSLocalizedString("First name", comment: "User info: First name"),
			childView: firstNameTextField,
			initialTextValue: user.firstName
		)
		let lastNameSection = UserDetailsSectionView(
			labelText: NSLocalizedString("Last name", comment: "User info: Last name"),
			childView: lastNameTextField,
			initialTextValue: user.lastName
		)
		let dateSection = UserDetailsSectionView(
			labelText: NSLocalizedString("Date of birth", comment: "User info: Date of birth"),
			childView: dateTextField,
			initialTextValue: user.dateOfBirth.map(formatDate)
		)
		let genderSection = UserDetailsSectionView(
			labelText: NSLocalizedString("Gender", comment: "User info: Gender"),
			childView: genderTextField,
			initialTextValue: user.gender?.translateValue()
		)
		let workSection = UserDetailsSectionView(
			labelText: NSLocalizedString("Work", comment: "User info: Work"),
			childView: workTextField,
			initialTextValue: user.work
		)
		let descriptionSection = UserDetailsSectionView(
			labelText: NSLocalizedString("Additional information", comment: "User info: Additional info"),
			childView: descriptionTextView,
			initialTextValue: user.description
		)
		return [
			firstNameSection,
			lastNameSection,
			dateSection,
			genderSection,
			workSection,
			descriptionSection
		]
	}
  
	private func setupView(user: User) {
    backgroundColor = .background
    scrollView.showsVerticalScrollIndicator = false
		
		let sections = setupSections(user: user)
		
		nameSectionStackView.axis = .vertical
		nameSectionStackView.spacing = 15
    sections.prefix(2)
			.forEach { nameSectionStackView.addArrangedSubview($0) }
		
		otherSectionsStackView.axis = .vertical
		otherSectionsStackView.spacing = 15
    sections.dropFirst(2)
			.forEach { otherSectionsStackView.addArrangedSubview($0) }
		
		genderTextField.inputView = genderPicker

    setupHeader()
    setupAvatarButton()
    setupDateTextField()
    setupDescriptionTextView()
    setupSubmitButton()

		contentView.sv([
			headerContainer,
			nameSectionStackView,
			otherSectionsStackView,
			avatarImageView,
			submitButton
		])
    sv(scrollView.sv(contentView))
		setupViewsConstraints()
  }
  
  private func setupHeader() {
    let titleLabel = UILabel()
    styleText(
      label: titleLabel,
      text: NSLocalizedString(
        "Tell other users about yourself!",
        comment: "Textfield to write about yourself"
      ),
      size: 26,
      color: .fontLabel,
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
        textColor: .fontLabel,
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
  
  private func setupAvatarButton() {
    avatarImageView.style({ v in
			v.layer.cornerRadius = Constants.avatarImageSize.width / 2
      v.backgroundColor = .highlightBlue
			v.clipsToBounds = true
			v.contentMode = .center
    })
  }
	
	@objc private func selectDate() {
		dateTextField.text = formatDate(datePicker.date)
    endEditing(true)
	}
  
  private func setupDateTextField() {
    let toolBar = UIToolbar()
    let tabBarCloseButton = UIBarButtonItem(
      title: NSLocalizedString("Close", comment: "Date picker: close"),
      style: .done,
      target: self,
      action: #selector(endEditing)
    )
    let spaceButton = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil
    )
    let tabBarDoneButton = UIBarButtonItem(
      title: NSLocalizedString("Select", comment: "Date picker: select date"),
      style: .done,
      target: self,
      action: #selector(selectDate)
    )
    datePicker.datePickerMode = .date
    toolBar.sizeToFit()
    toolBar.setItems([tabBarCloseButton, spaceButton, tabBarDoneButton], animated: false)
    dateTextField.inputAccessoryView = toolBar
    dateTextField.inputView = datePicker
  }
  
  private func setupDescriptionTextView() {
    styleText(
      textView: descriptionTextView,
      text: "",
      size: 16,
      color: .fontLabel,
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
      color: .blueButtonFont,
      style: .medium
    )
    submitButton.backgroundColor = .blueButtonBackground
  }
  
  private func setupViewsConstraints() {
    scrollView.left(0).right(0)
    scrollView.Bottom == safeAreaLayoutGuide.Bottom
    scrollView.Top == safeAreaLayoutGuide.Top
    contentView.fillContainer().centerInContainer()
    headerContainer.left(25).right(15).top(20)
		
		nameSectionStackView.left(15)
    nameSectionStackView.Top == headerContainer.Bottom + 50
    avatarImageView.CenterY == nameSectionStackView.CenterY
    avatarImageView
      .right(15)
			.width(Constants.avatarImageSize.width)
			.height(Constants.avatarImageSize.height)
    nameSectionStackView.Right == avatarImageView.Left - 10
		otherSectionsStackView.left(15).right(15)
		otherSectionsStackView.Top == nameSectionStackView.Bottom + 15
		
    submitButton.CenterX == contentView.CenterX
    submitButton.bottom(50).width(200)
  }
	
	private func formatDate(_ date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd LLLL YYYY"
		dateFormatter.locale = Locale(identifier: "ru_RU")
		return dateFormatter.string(from: date)
	}
}
