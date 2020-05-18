//
//  Drawer.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class Drawer {
  private let view: UIView
  private let palette = PaletteView()

  init(inside view: UIView) {
    self.view = view
    setupGestureRecognisers()
    view.sv(palette)
    palette.CenterX == view.CenterX
    palette
      .bottom(120)
      .width(palette.totalWidth)
      .height(palette.totalHeight)
  }

  private func setupGestureRecognisers() {
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    view.addGestureRecognizer(panGestureRecognizer)
    view.addGestureRecognizer(tapGestureRecognizer)
  }

  @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {

  }

  @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {

  }
}
