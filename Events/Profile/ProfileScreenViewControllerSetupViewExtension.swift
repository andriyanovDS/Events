//
//  ProfileScreenViewControllerSetupViewExtension
//  Events
//
//  Created by Дмитрий Андриянов on 28/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import SwiftIconFont
import Stevia

private let AVATAR_VIEW_SIZE: CGFloat = 80

extension ProfileScreenViewController {

    func setupView() {
        view.backgroundColor = .white
        setupContentView()
        setupUserInfoView()
        setupStackView()
        setupLogoutButton()
    }

    func setupContentView() {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(contentView)
        view.addSubview(scrollView)

        setupScrollViewConstraints(scrollView)
        setupContentViewConstraints(scrollView: scrollView)
    }

    func setupUserInfoView() {
        contentView.addSubview(userInfoView)
        setupUserInfoViewConstraints()
        setupAvatarView()
        setupUserNameLabel()
        setupEditButton()
    }

    func setupUserNameLabel() {
        userNameLabel.textColor = UIColor.gray800()
        userNameLabel.font = UIFont.init(name: "CeraPro-Medium", size: 32)
        userInfoView.addSubview(userNameLabel)
        setupUserNameLabelConstraints()
    }

    func setupEditButton() {
        let button = UIButtonScaleOnPress()
        let icon = UIImage(
            from: .materialIcon,
            code: "create",
            textColor: UIColor.gray400(),
            backgroundColor: .clear,
            size: CGSize(width: 25, height: 25)
        )
        button.setImage(icon, for: .normal)
        button.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        userInfoView.addSubview(button)
        setupEditButtonConstraints(button)
    }

    func setupAvatarView() {
        avatarViewButton.backgroundColor = UIColor.gray200()
        avatarViewButton.layer.cornerRadius = AVATAR_VIEW_SIZE/2
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = AVATAR_VIEW_SIZE/2
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UIImage(
            from: .materialIcon,
            code: "person",
            textColor: UIColor.gray800(),
            backgroundColor: .clear,
            size: CGSize(width: 50, height: 50)
        )

        avatarViewButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        avatarViewButton.addSubview(avatarImageView)
        userInfoView.addSubview(avatarViewButton)
        setupAvatarViewConstraints()
        setupAvatarImageViewConstraints()
    }

    func setupStackView() {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        contentView.addSubview(stackView)
        setupStackViewConstraints(stackView)
        let section = ProfileActionSection(labelText: "Создать задание", subtitleText: nil, iconName: "event")
        let section2 = ProfileActionSection(labelText: "Настройки", subtitleText: nil, iconName: "settings")
        stackView.addArrangedSubview(section)
        stackView.addArrangedSubview(section2)
    }

    func setupScrollViewConstraints(_ scrollView: UIView) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25)
            ])
    }

    func setupContentViewConstraints(scrollView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
            ])
    }

    func setupUserInfoViewConstraints() {
        userInfoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            userInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            userInfoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            userInfoView.heightAnchor.constraint(equalToConstant: 80)
            ])
    }

    func setupAvatarViewConstraints() {
        avatarViewButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarViewButton.topAnchor.constraint(equalTo: userInfoView.topAnchor),
            avatarViewButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            avatarViewButton.widthAnchor.constraint(equalToConstant: 80),
            avatarViewButton.heightAnchor.constraint(equalToConstant: 80)
            ])
    }

    func setupAvatarImageViewConstraints() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: avatarViewButton.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: avatarViewButton.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: AVATAR_VIEW_SIZE),
            avatarImageView.heightAnchor.constraint(equalToConstant: AVATAR_VIEW_SIZE)
            ])
    }

    func setupUserNameLabelConstraints() {
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNameLabel.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor),
            userNameLabel.centerYAnchor.constraint(equalTo: avatarViewButton.centerYAnchor)
            ])
    }

    func setupEditButtonConstraints(_ button: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor, constant: 10),
            button.centerYAnchor.constraint(equalTo: userNameLabel.centerYAnchor)
            ])
    }

    func setupStackViewConstraints(_ stackView: UIView) {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 50),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
    }

    func setupLogoutButton() {
        let button = ButtonWithBorder()

        button.setTitle("Выйти", for: .normal)
        button.setTitleColor(UIColor.gray600(), for: .normal)
        button.layer.borderColor = UIColor.gray600().cgColor
        button.titleLabel?.font = UIFont(name: "CeraPro-Medium", size: 20)
        button.addTarget(self, action: #selector(onLogout), for: .touchUpInside)

        view.addSubview(button)
        setupLogoutButtonConstraints(button)
    }

    func setupLogoutButtonConstraints(_ button: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -70),
            button.heightAnchor.constraint(equalToConstant: 45)
            ])
    }
}
