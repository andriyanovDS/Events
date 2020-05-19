//
//  PaletteView.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class PaletteView: UIView {
  var totalHeight: CGFloat {
    let rect = CGRect(x: 0, y: 0, width: totalWidth, height: 0)
    guard let firstPosition = layerPositions(in: rect, neededCount: 1).first else {
      return CGFloat.zero
    }
    return firstPosition.y + layers[0].bounds.height / 2
  }
  var totalWidth: CGFloat {
    let count = CGFloat(layers.count)
    return Constants.colorCircleRadius * 2 * count + Constants.colorSpacing * count
  }
  var selectedColor = PaletteColor.allCases[0]
  private var layers: [CAShapeLayer] = []
  private var selectedLayer: CAShapeLayer?
  private var selectionAnimation: CABasicAnimation = {
    let animation = CABasicAnimation(keyPath: "transform.scale")
    animation.fromValue = 1
    animation.toValue = 0.9
    animation.autoreverses = true
    animation.duration = 0.2
    animation.timingFunction = .easeOut
    return animation
  }()
  private var selectionLayer: CALayer = {
    let layer = CAShapeLayer()
    layer.fillColor = UIColor.white.cgColor
    let path = UIBezierPath(
      arcCenter: CGPoint(x: 0, y: 0),
      radius: Constants.selectionCircleRadius,
      startAngle: 0,
      endAngle: .pi * 2,
      clockwise: true
    )
    layer.path = path.cgPath
    return layer
  }()
  private lazy var feedbackGenerator = UISelectionFeedbackGenerator()

  init() {
    super.init(frame: CGRect.zero)

    layers = PaletteColor.allCases.map { layer(filled: $0) }
    layers.forEach { layer.addSublayer($0) }
    selectLayer(at: 0, animated: false)
    layer.backgroundColor = UIColor.red.cgColor

    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
    addGestureRecognizer(panGestureRecognizer)
    addGestureRecognizer(tapGestureRecognizer)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func layerPositions(in rect: CGRect, neededCount: Int) -> [CGPoint] {
    let radius = Double(rect.width / 2)
    let circumference = .pi * radius
    let count = circumference / Double(layers[0].bounds.width)
    let step = .pi / count.rounded(.down)
    let radiansOffset: Double = .pi/2 + Double(layers.count - 1)/2 * step
    
    return [Int](0..<neededCount).map { index in
      let angel = step * Double(index) - radiansOffset
      return CGPoint(
        x: radius * cos(angel) + radius,
        y: radius * sin(angel) + radius + Double(Constants.colorCircleRadius)
      )
    }
  }

  override func draw(_ rect: CGRect) {
    let positions = layerPositions(in: rect, neededCount: layers.count)
    
    let initialPosition = CGPoint(x: rect.width/2, y: rect.height)
    layers.forEach { $0.position = initialPosition }
    
    for index in 0..<layers.count {
      let appearanceAnimation = CASpringAnimation(keyPath: "position")
      appearanceAnimation.fromValue = initialPosition
      appearanceAnimation.toValue = positions[index]
      appearanceAnimation.damping = 10
      appearanceAnimation.duration = appearanceAnimation.settlingDuration
      layers[index].add(appearanceAnimation, forKey: nil)
      layers[index].position = positions[index]
    }
  }

  private func layer(filled color: PaletteColor) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.lineWidth = 4
    layer.strokeColor = UIColor.white.cgColor
    layer.fillColor = color.value.cgColor
    layer.fillRule = .evenOdd
    let size = Constants.colorCircleRadius * 2 + Constants.colorSpacing
    layer.bounds = CGRect(
      x: 0,
      y: 0,
      width: size,
      height: size
    )
    let path = UIBezierPath(
      arcCenter: CGPoint(x: layer.bounds.midX, y: layer.bounds.midY),
      radius: Constants.colorCircleRadius,
      startAngle: 0,
      endAngle: .pi * 2,
      clockwise: false
    )
    layer.path = path.cgPath
    return layer
  }

  private func selectLayer(at index: Int, animated: Bool = true) {
    let touchedLayer = layers[index]
    if touchedLayer == selectedLayer { return }

    selectionLayer.removeFromSuperlayer()
    selectedLayer = touchedLayer

    touchedLayer.addSublayer(selectionLayer)
    selectionLayer.position = CGPoint(x: touchedLayer.bounds.midX, y: touchedLayer.bounds.midY)
    selectedColor = PaletteColor.allCases[index]
    if animated {
      touchedLayer.add(selectionAnimation, forKey: "scale")
    }
  }

  private func didPerformGesture(at location: CGPoint) {
    guard let index = layers.firstIndex(where: { $0.frame.contains(location) }) else {
      return
    }

    guard layers[index] != selectedLayer else { return }
    selectLayer(at: index)
    feedbackGenerator.selectionChanged()
    feedbackGenerator.prepare()
  }

  @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began, .changed:
      didPerformGesture(at: recognizer.location(in: self))
    default: return
    }
  }

  @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
    switch recognizer.state {
    case .ended:
      didPerformGesture(at: recognizer.location(in: self))
    default: return
    }
  }
}

extension PaletteView {
  struct Constants {
    static let colorCircleRadius: CGFloat = 17.0
    static let colorSpacing: CGFloat = 17.0
    static let selectionCircleRadius: CGFloat = 6.0
  }

  enum PaletteColor: CaseIterable {
    case purple
    case green
    case plum
    case blue
    case yellow

    var value: UIColor {
      switch self {
      case .purple:
        return UIColor(red: 147/255, green: 112/255, blue: 219/255, alpha: 1)
      case .green:
        return UIColor(red: 0, green: 255, blue: 127/255, alpha: 1)
      case .plum:
        return UIColor(red: 221/255, green: 160/255, blue: 221/255, alpha: 1)
      case .blue:
        return UIColor(red: 70/255, green: 130/255, blue: 180/255, alpha: 1)
      case .yellow:
        return UIColor(red: 1, green: 215/255, blue: 0, alpha: 1)
      }
    }
  }
}
