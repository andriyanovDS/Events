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
    let centerIndex = CGFloat((layers.endIndex - 1) / 2)
    return Constants.colorCircleRadius * 2 + centerIndex * Constants.colorCircleRadius / 2
  }
  var totalWidth: CGFloat {
    let count = CGFloat(layers.count)
    return Constants.colorCircleRadius * 2 * count + Constants.colorSpacing * (count - 1)
  }
  private var layers: [CAShapeLayer] = []
  private var selectedColor = PaletteColor.allCases[0]
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

    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
    addGestureRecognizer(panGestureRecognizer)
    addGestureRecognizer(tapGestureRecognizer)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ rect: CGRect) {
    let centerLayerIndex = (layers.endIndex - 1) / 2
    var index = 0
    var pairIndex = layers.endIndex - index - 1
    while index <= centerLayerIndex {
      let verticalDiff = CGFloat(centerLayerIndex - index) * Constants.colorCircleRadius
       layers[index].position = CGPoint(
         x: CGFloat(index) * (Constants.colorCircleRadius * 2 + Constants.colorSpacing),
         y: verticalDiff
       )
       layers[pairIndex].position = CGPoint(
         x: CGFloat(pairIndex) * (Constants.colorCircleRadius * 2 + Constants.colorSpacing),
         y: verticalDiff
       )
       index += 1
       pairIndex -= 1
     }
  }

  private func layer(filled color: PaletteColor) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.lineWidth = 4
    layer.strokeColor = UIColor.white.cgColor
    layer.fillColor = color.value.cgColor
    layer.fillRule = .evenOdd
    let path = UIBezierPath(
      arcCenter: CGPoint(x: Constants.colorCircleRadius, y: Constants.colorCircleRadius),
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
    selectionLayer.position = CGPoint(x: Constants.colorCircleRadius, y: Constants.colorCircleRadius)
    selectedColor = PaletteColor.allCases[index]
    if animated {
      touchedLayer.add(selectionAnimation, forKey: "scale")
    }
  }

  private func didPerformGesture(at location: CGPoint) {
    let hitSize = Constants.colorCircleRadius * 2 + Constants.colorSpacing
    let index = min(
      max(Int((location.x + Constants.colorSpacing) / hitSize), 0),
      layers.endIndex - 1
    )

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
