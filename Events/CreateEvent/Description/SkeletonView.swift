//
//  SkeletonView.swift
//  Events
//
//  Created by Dmitry on 11.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class SkeletonView: UIView {
	
	private struct Constants {
		static let lineHeight: CGFloat = 6.0
		static let lineSpacing: CGFloat = 3.0
		static let lineWidths: [CGFloat] = [
			1,
			0.9,
			0.9,
			0.95,
			1
		]
	}
	
	private var width: CGFloat {
    return bounds.width
  }
	
	override func draw(_ rect: CGRect) {
		let linesCount = floor(bounds.height / (Constants.lineHeight + Constants.lineSpacing))
		let range = [Int](0...Int(linesCount) - 1)
		let path = UIBezierPath()
		range.forEach { drawSkeletonLine(path: path, at: $0)  }
	}
	
	private func drawSkeletonLine(path: UIBezierPath, at index: Int) {
		let lineWithSpacingHeight = Constants.lineHeight + Constants.lineSpacing
		let rectPath = UIBezierPath(
			roundedRect: CGRect(
				x: 2,
				y: lineWithSpacingHeight * CGFloat(index),
				width: (width - 4.0) * Constants.lineWidths[index % Constants.lineWidths.count],
				height: Constants.lineHeight
			),
			byRoundingCorners: .allCorners,
			cornerRadii: CGSize(width: 2.0, height: 2.0)
		)
		UIColor.skeletonBackground.setFill()
    rectPath.fill()
		path.append(rectPath)
	}
}
