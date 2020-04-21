//
//  EventAdditionalInfoView.swift
//  Events
//
//  Created by Dmitry on 20.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EventAdditionalInfoView: UIView {
  let stackView = UIStackView()
  private let backgroundView = UIView()
  
  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func addSections(_ sections: [UIView]) {
    sections
      .chunks(2)
      .map { sections -> UIView in
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        sections.forEach { stackView.addArrangedSubview($0) }
        return stackView
      }
      .forEach { stackView.addArrangedSubview($0) }
  }
  
  private func setupView() {
    backgroundView.backgroundColor = .textField
    backgroundView.layer.cornerRadius = 20
    
    sv([backgroundView, stackView])
    backgroundView.left(0).right(0).top(0)
    backgroundView.Bottom == stackView.Bottom + 10
    stackView.left(10).right(10).top(10).bottom(0)
  }
}
