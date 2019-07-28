//
//  DayButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 25/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class DayButton: UIButton {

    var isToday: Bool = false

    var selectedDate: Date?

    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.3 : 1
        }
    }

    var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.lightBlue().cgColor
        return layer
    }()

    lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()

    var halfOfWidth: CGFloat {
        return bounds.width / 2
    }

    var halfOfHeight: CGFloat {
        return bounds.height / 2
    }

    override var bounds: CGRect {
        didSet {
            if higlightState != ButtonHiglightState.notSelected {
                drawHighlightFor(state: higlightState)
            }
            if isToday {
                drawSelectionToday()
            }
        }
    }

    var higlightState: ButtonHiglightState = .notSelected {
        willSet (nextState) {
            if higlightState == nextState || bounds.height == 0 {
                return
            }
            drawHighlightFor(state: nextState)
        }
    }

    func drawSelectionToday() {
        let path = UIBezierPath(
            arcCenter: CGPoint(x: halfOfWidth, y: halfOfHeight),
            radius: halfOfHeight - 1,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        path.lineWidth = 1
        borderLayer.strokeColor = UIColor.gray400().cgColor
        borderLayer.path = path.cgPath
        self.layer.insertSublayer(borderLayer, at: 0)
    }

    func drawSingleSelection() {
        let path = UIBezierPath(
            arcCenter: CGPoint(x: halfOfWidth, y: halfOfHeight),
            radius: halfOfHeight,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        backgroundLayer.path = path.cgPath
        self.layer.insertSublayer(backgroundLayer, at: 0)
    }

    func drawSelectionInRange() {
        let rectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        backgroundLayer.path = rectanglePath.cgPath
        self.layer.insertSublayer(backgroundLayer, at: 0)
    }

    func drawSelectionFrom() {
        let center = CGPoint(x: halfOfWidth, y: halfOfHeight)
        let semicirclePath = UIBezierPath(
            arcCenter: center,
            radius: halfOfHeight,
            startAngle: .pi / 2,
            endAngle: 3 * .pi / 2,
            clockwise: true
        )
        let rectanglePath = UIBezierPath(rect: CGRect(x: halfOfWidth, y: 0, width: halfOfWidth, height: bounds.height))
        semicirclePath.append(rectanglePath)
        backgroundLayer.path = semicirclePath.cgPath
        self.layer.insertSublayer(backgroundLayer, at: 0)
    }

    func drawSelectionTo() {
        let center = CGPoint(x: halfOfWidth, y: halfOfHeight)
        let semicirclePath = UIBezierPath(
            arcCenter: center,
            radius: halfOfHeight,
            startAngle: 3 * .pi / 2,
            endAngle: .pi / 2,
            clockwise: true
        )
        let rectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: halfOfWidth, height: bounds.height))
        semicirclePath.append(rectanglePath)
        backgroundLayer.path = semicirclePath.cgPath
        self.layer.insertSublayer(backgroundLayer, at: 0)
    }

    private func drawHighlightFor(state: ButtonHiglightState) {
        switch state {
        case .single:
            setTitleColor(.white, for: .normal)
            drawSingleSelection()
        case .from:
            setTitleColor(.white, for: .normal)
            drawSelectionFrom()
        case .to:
            setTitleColor(.white, for: .normal)
            drawSelectionTo()
        case .inRange:
            setTitleColor(.white, for: .normal)
            drawSelectionInRange()
        default:
            if isToday {
                drawSelectionToday()
            }
            setTitleColor(UIColor.gray600(), for: .normal)
            backgroundLayer.removeFromSuperlayer()
        }
    }
}
