//
//  CalendarDayCell.swift
//  Events
//
//  Created by Dmitry on 16.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CalendarDayCell: UICollectionViewCell {
  var states: [HighlightState] = [] {
    didSet { addHighlights() }
  }
  let label = UILabel()
  var isInPast: Bool = false {
    didSet {
      label.alpha = isInPast ? 0.6 : 1
    }
  }
  private var todayHighlightLayer = CAShapeLayer()
  private var selectionHighlightLayer = CAShapeLayer()
  
  static let reuseIdentifier = String(describing: CalendarDayCell.self)
  
  private var halfOfWidth: CGFloat { floor(bounds.width / 2) }
  private var viewCenter: CGPoint {
    CGPoint(x: halfOfWidth, y: bounds.height / 2)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addTodayHighlight() {
    guard todayHighlightLayer.path == nil else { return }
    
    let path = UIBezierPath(
      arcCenter: viewCenter,
      radius: halfOfWidth - 1,
      startAngle: 0,
      endAngle: 2 * .pi,
      clockwise: true
    )
    todayHighlightLayer.path = path.cgPath
  }

  private func addSelectionInRangeHighlight(for feature: Feature) {
    switch feature {
    case .firstInRow:
      let path = UIBezierPath(
        roundedRect: bounds,
        byRoundingCorners: [.topLeft, .bottomLeft],
        cornerRadii: CGSize(width: 5, height: 5)
      )
      selectionHighlightLayer.path = path.cgPath
      return
    case .lastInRow:
      let path = UIBezierPath(
        roundedRect: bounds,
        byRoundingCorners: [.topRight, .bottomRight],
        cornerRadii: CGSize(width: 5, height: 5)
      )
      selectionHighlightLayer.path = path.cgPath
      return
    case .both:
      let path = UIBezierPath(
        roundedRect: bounds,
        byRoundingCorners: [.allCorners],
        cornerRadii: CGSize(width: 5, height: 5)
      )
      selectionHighlightLayer.path = path.cgPath
      return
    case .none:
      let path = UIBezierPath(
        rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
      )
      selectionHighlightLayer.path = path.cgPath
      return
    }
  }
  
  private func selectionCornerHighlightPath(
    for feature: Feature,
    originX: CGFloat,
    width: CGFloat
  ) -> UIBezierPath {
    switch feature {
    case .firstInRow:
      return UIBezierPath(
        roundedRect: CGRect(x: originX, y: 0, width: width, height: bounds.height),
        byRoundingCorners: [.topLeft, .bottomLeft],
        cornerRadii: CGSize(width: 5, height: 5)
      )
    case .lastInRow:
      return UIBezierPath(
        roundedRect: CGRect(x: originX, y: 0, width: width, height: bounds.height),
        byRoundingCorners: [.topRight, .bottomRight],
        cornerRadii: CGSize(width: 5, height: 5)
      )
    case .none, .both:
      return UIBezierPath(
        rect: CGRect(x: originX, y: 0, width: width, height: bounds.height)
      )
    }
  }
  
  private func addSelectionHighlight(with rangeState: SelectedRangeState) {
    label.textColor = .fontLabelInverted
    switch rangeState {
    case .single:
      let path = UIBezierPath(
        arcCenter: viewCenter,
        radius: halfOfWidth,
        startAngle: 0,
        endAngle: 2 * .pi,
        clockwise: true
      )
      selectionHighlightLayer.path = path.cgPath
    case .lowerBound(let feature):
      let path = UIBezierPath(
        arcCenter: viewCenter,
        radius: bounds.height / 2,
        startAngle: .pi / 2,
        endAngle: .pi * 3 / 2,
        clockwise: true
      )
      path.append(selectionCornerHighlightPath(
        for: feature != .firstInRow ? feature : .none,
        originX: halfOfWidth,
        width: bounds.width - halfOfWidth
      ))
      selectionHighlightLayer.path = path.cgPath
    case .upperBound(let feature):
      let path = UIBezierPath(
        arcCenter: viewCenter,
        radius: bounds.height / 2,
        startAngle: .pi / 2,
        endAngle: .pi * 3 / 2,
        clockwise: false
      )
      path.append(selectionCornerHighlightPath(
        for: feature != .lastInRow ? feature : .none,
        originX: 0,
        width: halfOfWidth
      ))
      selectionHighlightLayer.path = path.cgPath
    case .insideRange(let feature):
      addSelectionInRangeHighlight(for: feature)
    }
  }
  
  private func addHighlights() {
    if states.isEmpty {
      todayHighlightLayer.path = nil
      selectionHighlightLayer.path = nil
      return
    }
    for state in states {
      switch state {
      case .today:
        addTodayHighlight()
      case .selected(let rangeState):
        addSelectionHighlight(with: rangeState)
        return
      }
    }
  }
  
  private func setupView() {
    styleText(
      label: label,
      text: "",
      size: 16,
      color: .fontLabel,
      style: .regular
    )
    contentView.sv(label)
    label.centerInContainer()
    todayHighlightLayer.lineWidth = 2
    todayHighlightLayer.fillColor = UIColor.clear.cgColor
    todayHighlightLayer.strokeColor = UIColor.border.cgColor
    selectionHighlightLayer.fillColor = UIColor.selectionBlue.cgColor
    layer.insertSublayer(selectionHighlightLayer, at: 0)
    layer.insertSublayer(todayHighlightLayer, at: 1)
  }
  
  override func prepareForReuse() {
    states = []
    isInPast = false
    label.text = ""
    label.textColor = .fontLabel
    todayHighlightLayer.path = nil
    selectionHighlightLayer.path = nil
  }
}

extension CalendarDayCell {
  enum Feature {
    case firstInRow
    case lastInRow
    case both
    case none
  }
  
  enum SelectedRangeState {
    case lowerBound(feature: Feature)
    case upperBound(feature: Feature)
    case insideRange(feature: Feature)
    case single
  }
  
  enum HighlightState {
    case today
    case selected(rangeState: SelectedRangeState)
  }
}
