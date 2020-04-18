//
//  ListModalView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ListModalView: BottomModalView {
  let listView = UITableView()
  let closeButton = UIButton()
  let submitButton = ButtonScale()
  
  private let titleLabel = UILabel()

  init(titleText: String) {
		super.init(frame: CGRect.zero)
		titleLabel.text = titleText
  }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func setupView() {
    styleText(
      label: titleLabel,
			text: titleLabel.text ?? "",
      size: 22,
      color: .fontLabel,
      style: .bold
    )
    titleLabel.textAlignment = .center
    closeButton.setIcon(
      Icon(material: "cancel", sfSymbol: "xmark.circle.fill"),
      size: 30.0
    )

    styleText(
      button: submitButton,
      text: "Done",
      size: 18,
      color: .blueButtonFont,
      style: .medium
    )
    submitButton.backgroundColor = .blueButtonBackground

    listView.separatorStyle = .none
    listView.showsVerticalScrollIndicator = false
    contentView.sv([titleLabel, closeButton, listView, submitButton])
		super.setupView()
  }

  override func setupConstraints() {
		super.setupConstraints()
    titleLabel.top(10).centerHorizontally()
    closeButton.CenterY == titleLabel.CenterY
    closeButton.right(10).size(44)
    listView.Top == titleLabel.Bottom + 15
    listView.left(0).right(0)
    submitButton.left(10).right(10)
    submitButton.Bottom == safeAreaLayoutGuide.Bottom - 10
    listView.Bottom == submitButton.Top - 15
  }
}
