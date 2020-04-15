//
//  DescriptionCellButton.swift
//  Events
//
//  Created by Dmitry on 09.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class DescriptionCellButton: UIButton {
  private let _backgroundColor: UIColor
	
	private var halfWidth: CGFloat {
    return bounds.width / 2
  }

  private var halfHeight: CGFloat {
    return bounds.height / 2
  }
	
	init(backgroundColor: UIColor) {
		self._backgroundColor = backgroundColor
		super.init(frame: CGRect.zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
  override func draw(_ rect: CGRect) {
    drawCircle(rect: rect, color: .fontLabel)
    drawCircle(
      rect: CGRect(
        x: 1,
        y: 1,
        width: rect.width - 2,
        height: rect.height - 2
      ),
      color: _backgroundColor
    )
    drawPlus(lineWidth: 3, scale: 0.65, color: .fontLabel)
    drawPlus(lineWidth: 2, scale: 0.6, color: .fontLabelInverted)
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

protocol DescriptionCellButtonDataSource: class {
  var eventDescription: DescriptionWithAssets? { get }
}
