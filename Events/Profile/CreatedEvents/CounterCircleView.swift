//
//  CounterCircleView.swift
//  Events
//
//  Created by Dmitry on 31.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CounterCircleView: UIView {
	private var shapeLayer: CAShapeLayer = {
		let shapeLayer = CAShapeLayer()
		shapeLayer.strokeColor = UIColor.fontLabelInverted.cgColor
		shapeLayer.fillColor = UIColor.clear.cgColor
		shapeLayer.lineWidth = 3
		shapeLayer.lineCap = .round
		shapeLayer.strokeEnd = 1
		return shapeLayer
	}()
	
	override init(frame: CGRect = .zero) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func startAnimation() {
		shapeLayer.strokeEnd = 1
		let animation = CABasicAnimation(keyPath: "strokeEnd")
		animation.fromValue = 1
		animation.toValue = 0
		animation.duration = 5
		shapeLayer.add(animation, forKey: "strokeAnimation")
	}
	
	func stopAnimation() {
		shapeLayer.removeAllAnimations()
		shapeLayer.strokeEnd = 0
	}
	
	private func setupView() {
		layer.addSublayer(shapeLayer)
	}
	
	override func draw(_ rect: CGRect) {
		let radius = min(rect.width, rect.height) / 2 - shapeLayer.lineWidth
		let center = CGPoint(x: rect.midX, y: rect.midY)
		let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
		shapeLayer.path = path.cgPath
	}
}
