//
//  AddButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 05/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class AddButton: UIButton {

  private var halfWidth: CGFloat {
    return bounds.width / 2
  }

  private var halfHeight: CGFloat {
    return bounds.height / 2
  }

  override func draw(_ rect: CGRect) {
    drawCircle(rect: rect, color: .black)
    drawCircle(
      rect: CGRect(
        x: 1,
        y: 1,
        width: rect.width - 2,
        height: rect.height - 2
      ),
      color: .blue200()
    )
    drawPlus(lineWidth: 3, scale: 0.65, color: .black)
    drawPlus(lineWidth: 2, scale: 0.6, color: .white)
  }

  private func drawCircle(
    rect: CGRect,
    color: UIColor
  ) {
    let path = UIBezierPath(ovalIn: rect)
    color.setFill()
    path.fill()
  }

  private func drawPlus(
    lineWidth: CGFloat,
    scale: CGFloat,
    color: UIColor
  ) {
    let plusWidth: CGFloat = min(bounds.width, bounds.height) * scale
    let halfPlusWidth = plusWidth / 2

    let plusPath = UIBezierPath()
    plusPath.lineWidth = lineWidth
    plusPath.move(to: CGPoint(
      x: halfWidth - halfPlusWidth,
      y: halfHeight))
    plusPath.addLine(to: CGPoint(
      x: halfWidth + halfPlusWidth,
      y: halfHeight))

    plusPath.move(to: CGPoint(
      x: halfWidth,
      y: halfHeight - halfPlusWidth))
    plusPath.addLine(to: CGPoint(
      x: halfWidth,
      y: halfHeight + halfPlusWidth))
    color.setStroke()
    plusPath.stroke()
  }
}
