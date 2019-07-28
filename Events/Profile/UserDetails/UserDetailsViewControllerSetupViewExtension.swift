//
//  UserDetailsViewControllerSetupViewExtension.swift
//  Events
//
//  Created by Дмитрий Андриянов on 16/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import SwiftIconFont

extension UserDetailsViewController {

    func setupInitialView() {
        view.backgroundColor = .white

        setupScrollView()
        setupContentView()
        setupCloseButton()
        setupTitle()
        setupFirstNameSectionView()
        setupLastNameSectionView()
        setupAvatarView()
        setupDatePicker()
        setupGenderSectionView()
        setupWorkSectionView()
        setupDescriptionSectionView()
        setupSubmitButton()
    }

    func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        view.addSubview(scrollView)
        setupScrollViewConstraints()
    }

    func setupContentView() {
        scrollView.addSubview(contentView)
        setupContentViewConstraints()
    }

    func setupTitle() {
        titlelabel.text = "Расскажи другим пользователям о себе!"
        titlelabel.textColor = UIColor.gray900()
        titlelabel.font = UIFont(name: "CeraPro-Medium", size: 26)
        titlelabel.numberOfLines = 2
        titlelabel.textAlignment = .left

        contentView.addSubview(titlelabel)
        setupTitleConstraints()
    }

    func setupCloseButton() {
        let image = UIImage(
            from: .materialIcon,
            code: "cancel",
            textColor: UIColor.gray900(),
            backgroundColor: .clear,
            size: CGSize(width: 35, height: 35)
        )
        closeButton.setImage(image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)
        contentView.addSubview(closeButton)

        setupCloseButtonConstraints()
    }

    func setupFirstNameSectionView() {
        contentView.addSubview(firstNameSectionView)
        setupFirstNameSectionViewConstraints()

        firstNameSectionView.setupView(with: "Имя", childView: TextFieldWithBottomLine())
    }

    func setupLastNameSectionView() {
        contentView.addSubview(lastNameSectionView)
        setupLastNameSectionViewConstraints()
        lastNameSectionView.setupView(with: "Фамилия", childView: TextFieldWithBottomLine())
    }

    func setupAvatarView() {
        avatarView.layer.cornerRadius = 60
        avatarView.backgroundColor = .blue100()

        let image = UIImage(
            from: .materialIcon,
            code: "photo.camera",
            textColor: .black,
            backgroundColor: .clear,
            size: CGSize(width: 50, height: 50)
        )
        avatarView.setImage(image, for: .normal)
        avatarView.addTarget(
            self,
            action: #selector(showSelectImageActionSheet),
            for: .touchUpInside
        )
        contentView.addSubview(avatarView)
        setupAvatarViewConstraints(avatarView)
    }

    func setupDatePicker() {
        let toolBar = UIToolbar()
        let tabBarCloseButton = UIBarButtonItem(
            title: "Закрыть",
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
            title: "Выбрать",
            style: .done,
            target: self,
            action: #selector(selectDate)
        )
        datePicker.datePickerMode = .date
        toolBar.sizeToFit()
        toolBar.setItems([tabBarCloseButton, spaceButton, tabBarDoneButton], animated: false)
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker

        contentView.addSubview(dateSectionView)
        setupDatePickerConstraints()
        dateSectionView.setupView(with: "Дата рождения", childView: dateTextField)
    }

    func setupGenderSectionView() {
        contentView.addSubview(genderSectionView)
        setupGenderSectionViewConstraints()
        let picker = UIPickerView()
        picker.delegate = self
        genderTextField.inputView = picker
        genderSectionView.setupView(with: "Пол", childView: genderTextField)
    }

    func setupWorkSectionView() {
        contentView.addSubview(workSectionView)
        setupWorkSectionViewConstraints()
        let textField = TextFieldWithBottomLine()
        workSectionView.setupView(with: "Место работы", childView: textField)
    }

    func setupDescriptionSectionView() {
        descriptionTextView.isEditable = true
        descriptionTextView.textContainerInset = UIEdgeInsets(
            top: 0,
            left: 7,
            bottom: 0,
            right: 0
        )
        descriptionTextView.font = UIFont(name: "CeraPro-Medium", size: 16)
        descriptionTextView.textColor = UIColor.gray900()

        scrollView.addSubview(descriptionSetionView)
        setupDescriptionViewConstraints()
        descriptionSetionView.setupView(with: "Дополнительная информация", childView: descriptionTextView)
    }

    func setupSubmitButton() {
        let button = ButtonWithBorder()
        button.setTitle("Сохранить", for: .normal)
        button.layer.borderColor = UIColor.blue().cgColor
        button.setTitleColor(UIColor.blue(), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 0
        )
        button.titleLabel?.font = UIFont(name: "CeraPro-Medium", size: 20)
        button.addTarget(self, action: #selector(submitProfile), for: .touchUpInside)

        contentView.addSubview(button)
        setupSubmitButtonConstraints(button)
    }

    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }

    func setupContentViewConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
    }

    func setupCloseButtonConstraints() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 35),
            closeButton.heightAnchor.constraint(equalToConstant: 35)
            ])
    }

    func setupTitleConstraints() {
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titlelabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 60),
            titlelabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titlelabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: 10),
            titlelabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20)
            ])
    }

    func setupFirstNameSectionViewConstraints() {
        firstNameSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstNameSectionView.topAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 50),
            firstNameSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            firstNameSectionView.heightAnchor.constraint(equalToConstant: 60),
            firstNameSectionView.widthAnchor.constraint(equalToConstant: 180)
            ])
    }

    func setupLastNameSectionViewConstraints() {
        lastNameSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lastNameSectionView.topAnchor.constraint(equalTo: firstNameSectionView.bottomAnchor, constant: 15),
            lastNameSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lastNameSectionView.heightAnchor.constraint(equalToConstant: 60),
            lastNameSectionView.widthAnchor.constraint(equalToConstant: 180)
            ])
    }

    func setupAvatarViewConstraints(_ avatarView: UIView) {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.centerYAnchor.constraint(equalTo: lastNameSectionView.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: firstNameSectionView.trailingAnchor, constant: 30),
            avatarView.heightAnchor.constraint(equalToConstant: 120),
            avatarView.widthAnchor.constraint(equalToConstant: 120)
            ])
    }

    func setupDatePickerConstraints() {
        dateSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateSectionView.topAnchor.constraint(equalTo: lastNameSectionView.bottomAnchor, constant: 15),
            dateSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateSectionView.heightAnchor.constraint(equalToConstant: 60)
            ])
    }

    func setupGenderSectionViewConstraints() {
        genderSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            genderSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genderSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            genderSectionView.topAnchor.constraint(equalTo: dateSectionView.bottomAnchor, constant: 15),
            genderSectionView.heightAnchor.constraint(equalToConstant: 60)
            ])
    }

    func setupWorkSectionViewConstraints() {
        workSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            workSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            workSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            workSectionView.topAnchor.constraint(equalTo: genderSectionView.bottomAnchor, constant: 15),
            workSectionView.heightAnchor.constraint(equalToConstant: 60)
            ])
    }

    func setupDescriptionViewConstraints() {
        descriptionSetionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionSetionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionSetionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionSetionView.topAnchor.constraint(equalTo: workSectionView.bottomAnchor, constant: 15),
            descriptionSetionView.heightAnchor.constraint(equalToConstant: 120)
            ])
    }

    func setupSubmitButtonConstraints(_ button: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.topAnchor.constraint(equalTo: descriptionSetionView.bottomAnchor, constant: 30),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
    }

}
