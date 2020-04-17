//
//  CalendarSectionTitleView.swift
//  Events
//
//  Created by Dmitry on 16.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CalendarSectionTitleView: UICollectionReusableView {
  let label = UILabel()
  
  static let reusableIdentifier = String(describing: CalendarSectionTitleView.self)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    styleText(
      label: label,
      text: "",
      size: 18,
      color: .black,
      style: .medium
    )
    sv(label)
    label.left(0).centerVertically()
  }
  
  override func prepareForReuse() {
    label.text = ""
  }
}
