//
//  EditEventFooterView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

struct EditEventFooterButton {
  let icon: Icon
  let button: UIButton
}

class EditEventFooterView: UIView {
  private let buttons: [EditEventFooterButton]
  private let buttonsStackView = UIStackView()
  private var borderLayer: CALayer?

  override var bounds: CGRect {
    didSet { addBorder() }
  }

  init(buttons: [EditEventFooterButton]) {
    self.buttons = buttons
    super.init(frame: CGRect.zero)
    setupView()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func addBorder() {
    if
      let borderLayer = borderLayer,
      let sublayers = layer.sublayers,
      sublayers.contains(borderLayer) { return }
    
    let borderLayer = CALayer()
    borderLayer.backgroundColor = UIColor.border.cgColor
    borderLayer.frame = CGRect(
      x: bounds.minX + 10,
      y: bounds.minY,
      width: bounds.width - 20,
      height: 1
    )
    layer.addSublayer(borderLayer)
    self.borderLayer = borderLayer
  }

  private func setupView() {
    backgroundColor = .background
    buttonsStackView.axis = .horizontal
    buttonsStackView.spacing = 5
    buttonsStackView.alignment = .center
    buttons.forEach { v in
      v.button.setIcon(v.icon, size: 24, color: UIColor.grayButtonDarkFont)
      v.button.translatesAutoresizingMaskIntoConstraints = false
      v.button.width(40).height(40)
      buttonsStackView.addArrangedSubview(v.button)
    }
    sv(buttonsStackView)
    buttonsStackView.left(10).top(10).bottom(0)
  }
}
