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

        setupCloseButton()
        setupTitle()
        setupFirstNameSectionView()
        setupSurnameSectionView()
        setupAvatarView()
        setupDatePicker()
        setupGenderSectionView()
    }

    func setupTitle() {
        titlelabel.text = "Расскажи нам немного о себе!"
        titlelabel.textColor = UIColor.gray900()
        titlelabel.font = UIFont(name: "CeraPro-Medium", size: 32)
        titlelabel.numberOfLines = 2
        titlelabel.textAlignment = .left

        view.addSubview(titlelabel)
        setupTitleConstraints()
    }

    func setupCloseButton() {
        let button = UIButton()
        let image = UIImage(
            from: .materialIcon,
            code: "cancel",
            textColor: UIColor.gray900(),
            backgroundColor: .clear,
            size: CGSize(width: 35, height: 35)
        )
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(closeScreen), for: .touchUpInside)
        view.addSubview(button)

        setupCloseButtonConstraints(button)
    }

    func setupFirstNameSectionView() {
        view.addSubview(firstNameSectionView)
        setupFirstNameSectionViewConstraints()
        let firstNameTextField = TextFieldWithBottomLine()
        firstNameSectionView.setupView(with: "Имя", childView: firstNameTextField)
    }

    func setupSurnameSectionView() {
        view.addSubview(surnameSectionView)
        setupSurnameNameSectionViewConstraints()
        let surnameTextField = TextFieldWithBottomLine()
        surnameSectionView.setupView(with: "Фамилия", childView: surnameTextField)
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
        view.addSubview(avatarView)
        setupAvatarViewConstraints(avatarView)
    }

    func setupDatePicker() {
        datePicker = UIDatePicker()
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
        datePicker!.datePickerMode = .date
        toolBar.sizeToFit()
        toolBar.setItems([tabBarCloseButton, spaceButton, tabBarDoneButton], animated: false)
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker

        view.addSubview(dateSectionView)
        setupDatePickerConstraints()
        dateSectionView.setupView(with: "Дата рождения", childView: dateTextField)
    }

    func setupGenderSectionView() {
        view.addSubview(genderSectionView)
        setupGenderSectionViewConstraints()
        let genderTextField = TextFieldWithBottomLine()
        let picker = UIPickerView()
        picker.delegate = self
        genderTextField.inputView = picker
        genderSectionView.setupView(with: "Пол", childView: genderTextField)
    }

    func setupTitleConstraints() {
        titlelabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titlelabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titlelabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titlelabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70)
            ])
    }

    func setupCloseButtonConstraints(_ button: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            button.widthAnchor.constraint(equalToConstant: 35),
            button.heightAnchor.constraint(equalToConstant: 35)
            ])
    }

    func setupFirstNameSectionViewConstraints() {
        firstNameSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstNameSectionView.topAnchor.constraint(equalTo: titlelabel.bottomAnchor, constant: 30),
            firstNameSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameSectionView.heightAnchor.constraint(equalToConstant: 60),
            firstNameSectionView.widthAnchor.constraint(equalToConstant: 180)
            ])
    }

    func setupSurnameNameSectionViewConstraints() {
        surnameSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            surnameSectionView.topAnchor.constraint(equalTo: firstNameSectionView.bottomAnchor, constant: 15),
            surnameSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            surnameSectionView.heightAnchor.constraint(equalToConstant: 60),
            surnameSectionView.widthAnchor.constraint(equalToConstant: 180)
            ])
    }

    func setupAvatarViewConstraints(_ avatarView: UIView) {
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.centerYAnchor.constraint(equalTo: surnameSectionView.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: firstNameSectionView.trailingAnchor, constant: 30),
            avatarView.heightAnchor.constraint(equalToConstant: 120),
            avatarView.widthAnchor.constraint(equalToConstant: 120)
            ])
    }

    func setupDatePickerConstraints() {
        dateSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateSectionView.topAnchor.constraint(equalTo: surnameSectionView.bottomAnchor, constant: 15),
            dateSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateSectionView.heightAnchor.constraint(equalToConstant: 60)
            ])
    }

    func setupGenderSectionViewConstraints() {
        genderSectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            genderSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genderSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            genderSectionView.topAnchor.constraint(equalTo: dateSectionView.bottomAnchor, constant: 15),
            genderSectionView.heightAnchor.constraint(equalToConstant: 60)
            ])
    }

}
