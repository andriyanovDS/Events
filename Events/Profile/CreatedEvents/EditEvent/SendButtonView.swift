//
//  SendButtonView.swift
//  Events
//
//  Created by Dmitry on 03.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class SendButtonView: UIButtonScaleOnPress {
	private let cornerRadius: CGFloat
	
	private struct Constants {
		static let padding: CGFloat = 8.0
	}
	
	init(cornerRadius: CGFloat) {
		self.cornerRadius = cornerRadius
		super.init(frame: CGRect.zero)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ rect: CGRect) {
		guard let context = UIGraphicsGetCurrentContext() else { return }
		context.saveGState()
		let centerX = rect.width / 2
		
		context.addArc(
			center: CGPoint(
				x: centerX,
				y: rect.height / 2
			),
			radius: rect.width / 2,
			startAngle: 0,
			endAngle: .pi * 2,
			clockwise: true
		)
		context.setFillColor(UIColor.blueButtonBackground.cgColor)
		context.fillPath()
		
		let initialPoint = CGPoint(x: centerX, y: Constants.padding)
		let headHeight = centerX - Constants.padding

		context.setLineWidth(3)
		context.setLineCap(.round)
		context.setStrokeColor(UIColor.blueButtonFont.cgColor)
		
		context.move(to: initialPoint)
		context.addLine(to: CGPoint(x: centerX, y: rect.height - Constants.padding))

		context.setLineJoin(.round)
		context.addLines(between: [
			CGPoint(x: centerX - headHeight, y: Constants.padding + headHeight),
			initialPoint,
			CGPoint(x: centerX + headHeight, y: Constants.padding + headHeight)
		])
		
		context.strokePath()
		context.closePath()
	}
}
