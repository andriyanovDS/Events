//
//  ButtonScale.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ButtonScale: UIButtonScaleOnPress {

  override var isEnabled: Bool {
    didSet {
      self.alpha = isEnabled ? 1 : 0.5
    }
  }

  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    layer.cornerRadius = 8
    contentEdgeInsets = UIEdgeInsets(
      top: 8,
      left: 15,
      bottom: 8,
      right: 15
    )
    contentHorizontalAlignment = .center
    contentVerticalAlignment = .center
  }
}
