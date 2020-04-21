//
//  EventMainInfoView.swift
//  Events
//
//  Created by Dmitry on 20.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class EventMainInfoView: UIView {
  let categoryNameLabel = UILabel()
  let eventNameLabel = UILabel()
  let locationNameLabel = UILabel()
  private let stackView = UIStackView()
  
  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    styleText(
      label: categoryNameLabel,
      text: "",
      size: 16,
      color: .fontLabel,
      style: .medium
    )
    styleText(
      label: eventNameLabel,
      text: "",
      size: 24,
      color: .fontLabel,
      style: .bold
    )
    eventNameLabel.numberOfLines = 0
    styleText(
      label: locationNameLabel,
      text: "",
      size: 18,
      color: .fontLabel,
      style: .medium
    )
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.addArrangedSubview(categoryNameLabel)
    stackView.addArrangedSubview(eventNameLabel)
    stackView.addArrangedSubview(locationNameLabel)
    sv(stackView)
    stackView.fillContainer()
  }
}
