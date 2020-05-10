//
//  LoadingView.swift
//  Events
//
//  Created by Dmitry on 01.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class LoadingView: UIView {
	private struct Constants {
		static let animationDuration: TimeInterval = 600
		static let circlesCount: Int = 3
		static let circleRadius: CGFloat = 5.0
	}

  private let replicatorLayer = CAReplicatorLayer()
  private var circleLayer: CALayer = {
    let circleLayer = CAShapeLayer()
    let path = UIBezierPath(
      arcCenter: CGPoint.zero,
      radius: Constants.circleRadius,
      startAngle: 0,
      endAngle: .pi * 2,
      clockwise: true
    )
    circleLayer.path = path.cgPath
    circleLayer.fillColor = UIColor.backgroundInverted.cgColor
    return circleLayer
  }()

  init() {
    super.init(frame: CGRect.zero)
    replicatorLayer.addSublayer(circleLayer)
    layer.addSublayer(replicatorLayer)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

	override func draw(_ rect: CGRect) {
    replicatorLayer.frame = CGRect(
      x: rect.width / 2 - Constants.circleRadius * 4,
      y: 0,
      width: Constants.circleRadius * 9,
      height: Constants.circleRadius * 3
    )
    replicatorLayer.instanceCount = Constants.circlesCount
    let delayInMilliseconds = Int(Constants.animationDuration) / Constants.circlesCount
    replicatorLayer.instanceDelay = Double(delayInMilliseconds) / 1000

    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(Constants.circleRadius * 3, 0, 0)

		let animation = CABasicAnimation(keyPath: "transform.translation.y")
    animation.fromValue = 0
    animation.toValue = Constants.circleRadius * 3
		animation.autoreverses = true
		animation.duration = Constants.animationDuration / 1000
    animation.repeatCount = .infinity
    animation.timingFunction = .easeInOut

    circleLayer.add(animation, forKey: "tranlation")
	}
}
