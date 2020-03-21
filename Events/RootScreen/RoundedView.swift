//
//  EventCellImageBackground.swift
//  Events
//
//  Created by Дмитрий Андриянов on 19/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class RoundedView: UIView {
  let cornerRadii: CGSize
  let fillColor: UIColor

  init(cornerRadii: CGSize, backgroundColor: UIColor) {
    self.cornerRadii = cornerRadii
    fillColor = backgroundColor
    super.init(frame: CGRect.zero)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ rect: CGRect) {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: .allCorners,
      cornerRadii: cornerRadii
    )
    fillColor.setFill()
    path.fill()
    backgroundColor = .clear
  }
}
