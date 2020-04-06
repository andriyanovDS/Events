//
//  BottomModalView.swift
//  Events
//
//  Created by Dmitry on 06.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class BottomModalView: UIView, ModalView {
  let backgroundView = UIView()
  let contentView = UIView()
	
	func didLoad() {
		setupView()
    setupConstraints()
	}

	func setupView() {
    isOpaque = false
    backgroundColor = .clear
    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)

    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 15
    contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		
		sv([backgroundView, contentView])
  }

	func setupConstraints() {
    backgroundView.fillContainer()
    contentView.left(0).right(0).bottom(0)
  }
}
