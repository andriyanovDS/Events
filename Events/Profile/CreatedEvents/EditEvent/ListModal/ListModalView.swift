//
//  ListModalView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ListModalView: UIView {
  let backgroundView = UIView()
  let listView = UITableView()
  let closeButton = UIButton()
  let submitButton = ButtonScale()
  let contentView = UIView()
  
  private let titleLabel = UILabel()

  init(titleText: String) {
    super.init(frame: CGRect.zero)
    setupView(titleText: titleText)
    setupConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView(titleText: String) {
    isOpaque = false
    backgroundColor = .clear
    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)

    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 15
    contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    styleText(
      label: titleLabel,
      text: titleText,
      size: 22,
      color: .black,
      style: .bold
    )
    titleLabel.textAlignment = .center
    styleIcon(
      button: closeButton,
      iconCode: "close",
      size: 20,
      color: .gray600()
    )
    closeButton.backgroundColor = .gray200()
    closeButton.layer.cornerRadius = 15

    styleText(
      button: submitButton,
      text: "Done",
      size: 18,
      color: .white,
      style: .medium
    )
    submitButton.backgroundColor = .blue()

    listView.separatorStyle = .none
    listView.showsVerticalScrollIndicator = false
    contentView.sv([titleLabel, closeButton, listView, submitButton])
    sv([backgroundView, contentView])
  }

  private func setupConstraints() {
    backgroundView.fillContainer()
    contentView.left(0).right(0).bottom(0)
    titleLabel.top(10).centerHorizontally()
    closeButton.CenterY == titleLabel.CenterY
    closeButton.right(10).size(30)
    listView.Top == titleLabel.Bottom + 15
    listView.left(0).right(0)
    submitButton.left(10).right(10)
    submitButton.Bottom == safeAreaLayoutGuide.Bottom - 10
    listView.Bottom == submitButton.Top - 15
  }
}
