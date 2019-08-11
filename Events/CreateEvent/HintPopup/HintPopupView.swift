//
//  HintPopupView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 12/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class HintPopupView: UIView {
  let hintButton: HintView
  let backgroundView = UIView()

  init(popup: HintPopup) {
    hintButton = HintView(popup: popup)
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupView() {
    backgroundColor = .clear
    backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)

    sv(backgroundView, hintButton)

    backgroundView
      .centerInContainer()
      .fillContainer()

    hintButton
      .left(40)
      .right(40)
      .centerInContainer()
  }
}
