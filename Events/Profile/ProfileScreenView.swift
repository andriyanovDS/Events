//
//  ProfileScreenView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 30/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

private let AVATAR_VIEW_SIZE: CGFloat = 80

class ProfileScreenView: UIView {

    let scrollView = UIScrollView()
    let contentView = UIView()
    let userInfoView = UIView()
    let userNameLabel = UILabel()
    let avatarViewButton = UIButton()
    let avatarImageView = UIImageView()
    let editButton = UIButtonScaleOnPress()
    let logoutButton = ButtonWithBorder()

    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupButtons(_ buttons: [ProfileActionButton]) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill

        sv(stackView)
        stackView
            .left(25)
            .right(25)

        stackView.Top == userInfoView.Bottom + 40

        buttons.forEach({ v in
            stackView.addArrangedSubview(v)
        })
    }

    private func setupView() {
        backgroundColor = .white
        
        sv(
            scrollView.sv(contentView.sv([userInfoView]))
        )

        setupScrollView()
        contentView
            .fillContainer()
            .centerInContainer()
        setupUserInfoView()
        setupLogoutButton()
    }

    private func setupScrollView() {
        scrollView.style({ v in
            v.showsVerticalScrollIndicator = false
            v.showsHorizontalScrollIndicator = false
        })

        scrollView
            .left(25)
            .right(25)

        scrollView.Bottom == safeAreaLayoutGuide.Bottom
        scrollView.Top == safeAreaLayoutGuide.Top
    }

    private func setupUserInfoView() {
        userNameLabel.style({ v in
            v.textColor = UIColor.gray800()
            v.font = UIFont.init(name: "CeraPro-Medium", size: 32)
        })

        editButton.style({ v in
            let icon = UIImage(
                from: .materialIcon,
                code: "create",
                textColor: UIColor.gray400(),
                backgroundColor: .clear,
                size: CGSize(width: 25, height: 25)
            )
            v.setImage(icon, for: .normal)
        })

        avatarViewButton.style({ v in
            v.backgroundColor = UIColor.gray200()
            v.layer.cornerRadius = AVATAR_VIEW_SIZE/2
        })

        avatarImageView.style({ v in
            v.contentMode = .scaleAspectFill
            v.layer.cornerRadius = AVATAR_VIEW_SIZE/2
            v.clipsToBounds = true
            v.image = UIImage(
                from: .materialIcon,
                code: "person",
                textColor: UIColor.gray800(),
                backgroundColor: .clear,
                size: CGSize(width: 50, height: 50)
            )
        })

        userInfoView.sv([
            userNameLabel,
            editButton,
            avatarViewButton.sv([avatarImageView])
            ])
        setupUserInfoViewConstraints()
    }

    private func setupUserInfoViewConstraints() {
        userInfoView
            .top(40)
            .left(0)
            .right(0)
            .height(80)

        userNameLabel
            .left(0)
            .centerVertically()

        editButton.centerVertically()
        editButton.Left == userNameLabel.Right + 10

        avatarViewButton
            .right(0)
            .top(0)
            .height(80)
            .heightEqualsWidth()

        avatarImageView
            .centerInContainer()
            .width(80)
            .height(80)
    }

    private func setupLogoutButton() {
        logoutButton.style({ v in
            v.setTitle("Выйти", for: .normal)
            v.setTitleColor(UIColor.gray600(), for: .normal)
            v.layer.borderColor = UIColor.gray600().cgColor
            v.titleLabel?.font = UIFont(name: "CeraPro-Medium", size: 20)
        })

        contentView.sv(logoutButton)

        logoutButton
            .bottom(50)
            .left(50)
            .right(50)
            .height(45)
    }
}
