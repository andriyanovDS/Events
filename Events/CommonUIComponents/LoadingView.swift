//
//  LoadingView.swift
//  Events
//
//  Created by Dmitry on 01.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class LoadingView: UIView {
	private var viewCenterX: CGFloat = CGFloat.zero
	
	private struct Constants {
		static let animationDuration: TimeInterval = 600
		static let circlesCount: Int = 3
		static let circleRadius: CGFloat = 5.0
	}
	
	private func centerX(at index: Int) -> CGFloat {
		let centerIndex = Constants.circlesCount / 2
		if index == centerIndex { return viewCenterX }
		let difference = index - centerIndex
		return viewCenterX + Constants.circleRadius * 3 * CGFloat(difference)
	}
	
	override func draw(_ rect: CGRect) {
		viewCenterX = rect.width / 2
		let range = Array([Int](0...Constants.circlesCount - 1))
		
		let animation = CABasicAnimation(keyPath: "position")
		animation.autoreverses = true
		animation.duration = Constants.animationDuration / 1000
		animation.repeatCount = Float.greatestFiniteMagnitude
		animation.timingFunction = .linear
		
		range
			.enumerated()
			.forEach {(index, _) in drawCircle(at: index, withAnimation: animation)}
	}

	private func drawCircle(at index: Int, withAnimation animation: CABasicAnimation) {
		let startPoint = CGPoint(
			x: centerX(at: index),
			y: Constants.circleRadius
		)
		let endPoint = CGPoint(
			x: startPoint.x,
			y: Constants.circleRadius * 3
		)
		let delayInMilliseconds = Int(Constants.animationDuration) / Constants.circlesCount * index
		animation.timeOffset = Double(delayInMilliseconds) / 1000
		animation.fromValue = startPoint
		animation.toValue = endPoint
		
		let circleLayer = CAShapeLayer()
		circleLayer.position = startPoint
		let path = UIBezierPath(
			arcCenter: CGPoint.zero,
			radius: Constants.circleRadius,
			startAngle: 0,
			endAngle: .pi * 2,
			clockwise: true
		)
		circleLayer.path = path.cgPath
		circleLayer.fillColor = UIColor.black.cgColor
		circleLayer.position = startPoint
		self.layer.addSublayer(circleLayer)
		circleLayer.add(animation, forKey: nil)
	}
}
