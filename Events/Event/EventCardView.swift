//
//  EventCardView.swift
//  Events
//
//  Created by Dmitry on 01.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EventCardView: UIView {
  let imageView = UIImageView()
  let categoryLabel = UILabel()
  let titleLabel = UILabel()
  let locationLabel = UILabel()
  
  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    
    styleText(
      label: categoryLabel,
      text: "",
      size: 16,
      color: .fontLabelDescription,
      style: .medium
    )
    styleText(
      label: titleLabel,
      text: "",
      size: 22,
      color: .fontLabel,
      style: .bold
    )
    styleText(
      label: locationLabel,
      text: "",
      size: 16,
      color: .fontLabel,
      style: .medium
    )
    titleLabel.numberOfLines = 0
    sv([imageView, categoryLabel, titleLabel, locationLabel])
    imageView.top(0).left(0).right(0)
    categoryLabel.Top == imageView.Bottom + 15
    categoryLabel.left(15).right(15)
    titleLabel.left(15).right(15)
    titleLabel.Top == categoryLabel.Bottom + 6
    locationLabel.left(15).right(15).bottom(20).Top == titleLabel.Bottom + 6
  }
}
