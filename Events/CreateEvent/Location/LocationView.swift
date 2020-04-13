//
//  LocationView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class LocationView: UIView, CreateEventView {
	weak var delegate: LocationViewDelegate?
  private let locationButton = UIButton()
  private let submitButton = UIButton()
  private let contentView = UIView()
  private let titleLabel = UILabel()
  private let descriptionLabel = UILabel()

  init() {
    super.init(frame: CGRect.zero)
		setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
	
	func setLocationName(_ name: String) {
		locationButton.setTitle(name, for: .normal)
	}

  private func setupView() {
    backgroundColor = .white
    styleText(
      label: titleLabel,
      text: NSLocalizedString("Place of meeting", comment: "Create event: location section title"),
      size: 26,
      color: .fontLabel,
      style: .bold
    )

    styleText(
      label: descriptionLabel,
      text: NSLocalizedString(
        "Where will the event be held?",
        comment: "Create event: location section description"
      ),
      size: 18,
      color: .fontLabelDescription,
      style: .regular
    )

    styleText(
      button: selectButtonStyle(locationButton),
      text: "",
      size: 18,
      color: .grayButtonDarkFont,
      style: .medium
    )
		locationButton.titleEdgeInsets = UIEdgeInsets(
      top: 12,
      left: 10,
      bottom: 12,
      right: 10
    )
		locationButton.titleLabel?.numberOfLines = 2
    titleLabel.numberOfLines = 2
		sv(
			contentView.sv(
        [titleLabel, descriptionLabel, locationButton, submitButton]
      )
		)
    setupSubmitButton()
    setupConstraints()
		setupHandlers()
  }

  @objc private func onSubmitButtonDidPress() {
    delegate?.openNextScreen()
  }

  @objc private func onLocationButtonDidPress() {
    delegate?.openChangeLocationModal()
  }
	
	private func setupHandlers() {
		locationButton.addTarget(self, action: #selector(onLocationButtonDidPress), for: .touchUpInside)
		submitButton.addTarget(self, action: #selector(onSubmitButtonDidPress), for: .touchUpInside)
	}

  private func setupSubmitButton() {
    styleText(
      button: submitButton,
      text: NSLocalizedString("Next step", comment: "Create event: next step"),
      size: 20,
      color: .blueButtonFont,
      style: .medium
      )
    submitButton.contentEdgeInsets = UIEdgeInsets(
      top: 8,
      left: 15,
      bottom: 8,
      right: 15
    )
    submitButton.layer.cornerRadius = 8
    submitButton.backgroundColor = .blueButtonBackground
  }

  private func setupConstraints() {
    contentView.left(20).right(20)
    contentView.Top == safeAreaLayoutGuide.Top
    contentView.Bottom == safeAreaLayoutGuide.Bottom

    titleLabel
      .top(20%)
      .left(0)
      .right(0)

    align(vertically: [titleLabel, descriptionLabel, locationButton])

    layout(
      |-titleLabel-|,
      8,
      |-descriptionLabel-|,
      45,
      |-locationButton-|
    )

    submitButton.width(200).centerHorizontally()
    submitButton.Bottom == contentView.Bottom - 50
  }
}

protocol LocationViewDelegate: CreateEventViewDelegate {
	func openChangeLocationModal()
}
