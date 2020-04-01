//
//  LoadingView.swift
//  Events
//
//  Created by Dmitry on 01.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class LoadingView: UIView {
	private var tasks: [DispatchWorkItem] = []
	private var viewCenterX: CGFloat = CGFloat.zero
	
	private struct Constants {
		static let animationDuration: TimeInterval = 600
		static let circlesCount: Int = 3
		static let circleRadius: CGFloat = 5.0
	}
	
	deinit {
		tasks.forEach { $0.cancel() }
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
		let layers = range
			.enumerated()
			.map {(index, _) in drawCircle(at: index)}
		
		tasks = layers
			.enumerated()
			.map { (index, layer) in
				let task = DispatchWorkItem {[unowned self] in
					layer.startDownAnimation()
					if index == layers.count - 1 {
						self.tasks = []
					}
				}
				let delay = Int(Constants.animationDuration) / Constants.circlesCount * index
				DispatchQueue.main.asyncAfter(
					deadline: DispatchTime.now() + .milliseconds(delay),
					execute: task
				)
				return task
			}
	}

	private func drawCircle(at index: Int) -> LoadingViewLayer {
		let startPoint = CGPoint(
			x: centerX(at: index),
			y: Constants.circleRadius
		)
		let circleLayer = LoadingViewLayer(
			translationY: Constants.circleRadius * 3,
			animationDuration: Constants.animationDuration / 1000
		)
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
		return circleLayer
	}
}

private class LoadingViewLayer: CAShapeLayer {
	let translationY: CGFloat
	let animationDuration: TimeInterval
	private var activeAnimation: Animation = .down
	private var animation: CABasicAnimation = {
		let animation = CABasicAnimation(keyPath: "transform")
		animation.timingFunction = .linear
		return animation
	}()
	
	private enum Animation {
		case up, down
	}

	init(translationY: CGFloat, animationDuration: TimeInterval) {
		self.translationY = translationY
		self.animationDuration = animationDuration
		super.init()
		animation.delegate = self
		animation.duration = animationDuration
	}
	
	override init(layer: Any) {
		guard let layer = layer as? LoadingViewLayer else {
			fatalError("Unexpected layer")
		}
		translationY = layer.translationY
		animationDuration = layer.animationDuration
		super.init(layer: layer)
		animation.delegate = self
		animation.duration = animationDuration
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func startDownAnimation() {
		let animation = self.animation
		let transform = CATransform3DMakeTranslation(1, translationY, 1)
		animation.fromValue = CATransform3DIdentity
		animation.toValue = transform
		activeAnimation = .down
		self.transform = transform
		add(animation, forKey: nil)
	}
	
	private func startUpAnimation() {
		let animation = self.animation
		animation.fromValue = CATransform3DMakeTranslation(1, translationY, 1)
		animation.toValue = CATransform3DIdentity
		activeAnimation = .up
		transform = CATransform3DIdentity
		add(animation, forKey: nil)
	}
}

extension LoadingViewLayer: CAAnimationDelegate {
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if !flag { return }
		switch activeAnimation {
		case .up:
			startDownAnimation()
		case .down:
			startUpAnimation()
		}
	}
}
