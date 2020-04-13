//
//  ProfileScreenView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 30/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ProfileScreenView: UIView {
  
  let scrollView = UIScrollView()
  let contentView = UIView()
  let userInfoView = UIView()
  let userNameLabel = UILabel()
  let avatarViewButton = UIButton()
  let avatarImageView = UIImageView()
  let editButton = UIButtonScaleOnPress()
  let logoutButton = ButtonScale()
  
  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
	
	private struct Constants {
		static let avatarImageSize = CGSize(
			width: 80,
			height: 80
		)
	}
	
	func updateAvatar(imageUrl: String) {
		avatarImageView.fromExternalUrl(
			imageUrl,
			withResizeTo: Constants.avatarImageSize,
			loadOn: .global(qos: .default),
			transitionConfig: UIImageView.TransitionConfig(duration: 0.4)
		)
	}
  
  func setupButtons(_ buttons: [ProfileActionButton]) {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fillProportionally
    stackView.alignment = .fill
    buttons.forEach { stackView.addArrangedSubview($0) }
    sv(stackView)
    stackView.left(25).right(25)
    stackView.Top == userInfoView.Bottom + 40
  }
  
  private func setupView() {
    backgroundColor = .background
    
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
    
    scrollView.left(25).right(25)
    scrollView.Bottom == safeAreaLayoutGuide.Bottom
    scrollView.Top == safeAreaLayoutGuide.Top
  }
  
  private func setupUserInfoView() {
    styleText(
      label: userNameLabel,
      text: "",
      size: 32,
      color: .fontLabel,
      style: .medium
    )
    
    editButton.style({ v in
      let icon = UIImage(
        from: .materialIcon,
        code: "create",
        textColor: .fontLabel,
        backgroundColor: .clear,
        size: CGSize(width: 25, height: 25)
      )
      v.setImage(icon, for: .normal)
    })
    
    avatarViewButton.style({ v in
      v.backgroundColor = UIColor.grayButtonBackground
			v.clipsToBounds = true
			v.layer.cornerRadius = Constants.avatarImageSize.width / 2
    })
    
    avatarImageView.style({ v in
      v.contentMode = .scaleAspectFill
      v.image = UIImage(
        from: .materialIcon,
        code: "person",
        textColor: .fontLabel,
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
    styleText(
      button: logoutButton,
      text: "Выйти",
      size: 20,
      color: .grayButtonLightFont,
      style: .medium
    )
    logoutButton.backgroundColor = .grayButtonBackground
    contentView.sv(logoutButton)
    
    logoutButton
      .bottom(50)
      .left(50)
      .right(50)
      .height(45)
  }
}
