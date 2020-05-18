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
  private let paletteView = PaletteView()

  init(inside view: UIView) {
    self.view = view

    view.sv(paletteView)
    paletteView.CenterX == view.CenterX
    paletteView
      .bottom(120)
      .width(paletteView.totalWidth)
      .height(paletteView.totalHeight)
  }
}
