//
//  DescriptionView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 11/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class DescriptionView: UIView {
  let textView = UITextView()
  let selectImageButton = UIButtonScaleOnPress()
  let submitButton = ButtonWithBorder()
  private let contentView = UIView()
  private let label = UILabel()
  private let imagePickerView = UIView()
  private let allowMultipleImages: Bool

  init(allowMultipleImages: Bool) {
    self.allowMultipleImages = allowMultipleImages
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .white

    styleText(
      label: label,
      text: "Расскажи о мероприятии",
      size: 26,
      color: .gray900(),
      style: .bold
    )
    styleText(
      textView: textView,
      text: "",
      size: 16,
      color: .gray800(),
      style: .medium
    )
    styleText(
      button: submitButton,
      text: "Далее",
      size: 20,
      color: .blue,
      style: .medium
    )

    textView.style({ v in
      v.layer.cornerRadius = 5
      v.backgroundColor = UIColor.gray100(alpha: 0.4)
    })

    submitButton.style({ v in
      v.contentEdgeInsets = UIEdgeInsets(
        top: 7,
        left: 0,
        bottom: 7,
        right: 0
      )
      v.isEnabled = false
      v.layer.borderColor = UIColor.blue().cgColor
    })

    sv(contentView.sv([label, textView, imagePickerView, submitButton]))
    setupImagePicker()
    setupConstraints()
  }

  private func setupImagePicker() {
    let label = UILabel()
    selectImageButton.setImage(UIImage(named: "AddImage"), for: .normal)

    // TODO: add localization
    let labelText = self.allowMultipleImages
      ? "Добавить изображения"
      : "Добавить изображение"
    styleText(
      label: label,
      text: labelText,
      size: 18,
      color: .gray900(),
      style: .medium
    )
    imagePickerView.sv(selectImageButton, label)
    contentView.left(0).right(0)

    selectImageButton.left(0).top(0).width(40).height(40)
    label.Left == selectImageButton.Right + 20
    label.centerVertically()
  }

  private func setupConstraints() {
    contentView.left(20).right(20).centerInContainer()
    contentView.Top == safeAreaLayoutGuide.Top
    contentView.Bottom == safeAreaLayoutGuide.Bottom

    label.top(20).left(0).right(0)
    align(vertically: [label, textView, imagePickerView])
    layout(
      |-label-|,
      10,
      |-textView-|,
      10,
      |-imagePickerView.height(40)-|,
      15,
      |-submitButton.centerHorizontally().width(200)-|,
      30
    )
  }
}
