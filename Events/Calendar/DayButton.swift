//
//  DayButton.swift
//  Events
//
//  Created by Дмитрий Андриянов on 25/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

enum ButtonHiglightState {
  case from, to, inRange, single, notSelected
}

private enum DateFeature {
  case lastInMonth, firstInMonth, firstInWeek, lastInWeek
}

private func dayToDateFeature(day: Day) -> DateFeature? {
  if day.dayOfMonth == 1 {
    return .firstInMonth
  }
  if day.isLastInMonth {
    return .lastInMonth
  }
  if day.dayOfWeek == 1 {
    return .firstInWeek
  }
  if day.dayOfWeek == 7 {
    return .lastInWeek
  }
  return nil
}

class DayButton: UIButton {
  let isToday: Bool
  var date: Date? {
    day?.date
  }
  private let day: Day?
  private let dateFeature: DateFeature?

  override var isHighlighted: Bool {
    didSet {
      self.alpha = isHighlighted ? 0.3 : 1
    }
  }

  private var backgroundLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.fillColor = UIColor.lightBlue().cgColor
    return layer
  }()

  private var gradientLayer: CAGradientLayer = CAGradientLayer()

  private lazy var borderLayer: CAShapeLayer = {
    let layer = CAShapeLayer()
    layer.fillColor = UIColor.clear.cgColor
    return layer
  }()

  private var halfOfWidth: CGFloat {
    bounds.width / 2
  }

  private var halfOfHeight: CGFloat {
    bounds.height / 2
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

  init(day: Day?) {
    self.day = day
    isToday = day?.isToday ?? false
    dateFeature = day.chain { dayToDateFeature(day: $0) }
    super.init(frame: CGRect.zero)

    self.isEnabled = day
      .map { !$0.isInPast }
      .getOrElse(result: false)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func drawSelectionToday() {
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

  private func drawSingleSelection() {
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

  private func drawSelectionInRangeFirstDayOfMonth() {
    gradientLayer.frame = bounds
    gradientLayer.colors = [UIColor.lightBlue().cgColor, UIColor.white.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.6, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 0)
    gradientLayer.mask = nil
    let isLastDayOfWeek = day
      .map { $0.dayOfWeek == 7 }
      .getOrElse(result: false)
    if isLastDayOfWeek {
      gradientLayer.cornerRadius = 5
      gradientLayer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
    layer.insertSublayer(gradientLayer, at: 0)
  }

  private func drawSelectionInRangeLastDayOfMonth() {
    gradientLayer.frame = bounds
    gradientLayer.colors = [UIColor.lightBlue().cgColor, UIColor.white.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.4, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0)
    gradientLayer.mask = nil
    let isFirstDayOfWeek = day
     .map { $0.dayOfWeek == 1 }
     .getOrElse(result: false)
    if isFirstDayOfWeek {
      gradientLayer.cornerRadius = 5
      gradientLayer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    layer.insertSublayer(gradientLayer, at: 0)
  }

  private func drawSelectionInRangeRegular() {
    let rectanglePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
    backgroundLayer.path = rectanglePath.cgPath
    self.layer.insertSublayer(backgroundLayer, at: 0)
  }

  private func drawSelectionInRangeFirstDayOfWeek(radius: CGFloat) {
     let rectanglePath = UIBezierPath(
       roundedRect: bounds,
       byRoundingCorners: [.topLeft, .bottomLeft],
       cornerRadii: CGSize(width: radius, height: radius)
     )
     backgroundLayer.path = rectanglePath.cgPath
     self.layer.insertSublayer(backgroundLayer, at: 0)
   }

  private func drawSelectionInRangeLastDayOfWeek(radius: CGFloat) {
    let rectanglePath = UIBezierPath(
      roundedRect: bounds,
      byRoundingCorners: [.topRight, .bottomRight],
      cornerRadii: CGSize(width: radius, height: radius)
    )
    backgroundLayer.path = rectanglePath.cgPath
    self.layer.insertSublayer(backgroundLayer, at: 0)
  }

  private func drawSelectionInRange() {
    dateFeature.foldL(
      none: drawSelectionInRangeRegular,
      some: { feature in
        switch feature {
        case .firstInMonth:
          drawSelectionInRangeFirstDayOfMonth()
        case .lastInMonth:
          drawSelectionInRangeLastDayOfMonth()
        case .firstInWeek:
          drawSelectionInRangeFirstDayOfWeek(radius: 5)
        case .lastInWeek:
          drawSelectionInRangeLastDayOfWeek(radius: 5)
        }
      })
  }

  private func setupGradientLayerWithMask(path: CGPath, endPoint: CGPoint) {
    let gradientMask = CAShapeLayer()
    gradientMask.contentsScale = UIScreen.main.scale
    gradientMask.path = path

    gradientLayer.frame = bounds
    gradientLayer.mask = gradientMask
    gradientLayer.colors = [UIColor.lightBlue().cgColor, UIColor.white.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = endPoint
    backgroundLayer.addSublayer(gradientLayer)
  }

  private func drawSelectionFrom() {
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

    dateFeature
      .filter { $0 == .lastInMonth }
      .foldL(
        none: {},
        some: { _ in
          setupGradientLayerWithMask(
            path: semicirclePath.cgPath,
            endPoint: CGPoint(x: 1, y: 0)
          )
        }
      )

    self.layer.insertSublayer(backgroundLayer, at: 0)
  }

  private func drawSelectionTo() {
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

    dateFeature
      .filter { $0 == .firstInMonth }
      .foldL(
        none: {},
        some: { _ in
          setupGradientLayerWithMask(
            path: semicirclePath.cgPath,
            endPoint: CGPoint(x: 0, y: 0)
          )
        }
      )

    self.layer.insertSublayer(backgroundLayer, at: 0)
  }

  private func drawHighlightFor(state: ButtonHiglightState) {
    if !isEnabled { return }
    switch state {
    case .single:
      gradientLayer.removeFromSuperlayer()
      drawSingleSelection()
    case .from:
      gradientLayer.removeFromSuperlayer()
      drawSelectionFrom()
    case .to:
      gradientLayer.removeFromSuperlayer()
      drawSelectionTo()
    case .inRange:
      drawSelectionInRange()
    default:
      if isToday {
        drawSelectionToday()
      }
      backgroundLayer.removeFromSuperlayer()
      gradientLayer.removeFromSuperlayer()
    }
    setTitleColor(
      state == .notSelected
        ? .black
        : .white,
      for: .normal
    )
  }
}
