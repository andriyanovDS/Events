//
//  PermissionModalScreenView.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//
import UIKit
import Stevia

class PermissionModalView: UIView {
  let submitButton = ButtonScale()
  let titleLabel = UILabel()
  let descriptionLabel = UILabel()
  let imageView = UIImageView()
  let viewData: PermissionModal
  let closeButton = UIButton()
  
  init(modalType: PermissionModalType) {
    viewData = modalType.model()
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    backgroundColor = .background
    setupPopupView()
    sv(
      titleLabel,
      closeButton,
      descriptionLabel,
      imageView,
      submitButton
    )
    
    layout(
      70,
      closeButton-25-|,
      100,
      |-titleLabel-|,
      50,
      |-imageView-|,
      50,
      |-descriptionLabel-|
    )
    
    submitButton
      .bottom(150)
      .left(50)
      .right(50)
      .height(45)
  }
  
  private func setupPopupView() {
    styleText(
      label: titleLabel,
      text: viewData.title,
      size: 26,
      color: .fontLabel,
      style: .bold
    )
    titleLabel.style({ v in
      v.textAlignment = .center
    })
    
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
    
    styleText(
      label: descriptionLabel,
      text: viewData.description,
      size: 26,
      color: .fontLabel,
      style: .regular
    )
    descriptionLabel.style({ v in
      v.textAlignment = .center
      v.numberOfLines = 3
    })
    
    imageView.style({ v in
      v.layer.cornerRadius = 50/2
      v.translatesAutoresizingMaskIntoConstraints = false
      v.contentMode = .scaleAspectFit
      v.width(150)
      v.height(150)
      v.image = UIImage(named: viewData.image)
    })
    
    styleText(
      button: submitButton,
      text: viewData.buttonLabelText,
      size: 20,
      color: .blueButtonFont,
      style: .medium
    )
    submitButton.backgroundColor = .blueButtonBackground
  }
}
