//
//  CanvasView.swift
//  Events
//
//  Created by Dmitry on 18.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CanvasView: UIView {
  var lines: [ColoredLine] = []
  
  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    for line in lines {
      context.setStrokeColor(line.color)
      context.setLineCap(line.lineCap)
      context.setLineWidth(line.width)
      context.setBlendMode(line.blendMode)
      
      for (index, point) in line.points.enumerated() {
        if index == 0 {
          context.move(to: point)
          continue
        }
        context.addLine(to: point)
      }
      context.strokePath()
    }
  }
}

extension CanvasView {
  struct ColoredLine {
    let color: CGColor
    let blendMode: CGBlendMode
    let width: CGFloat
    let lineCap: CGLineCap
    var points: [CGPoint]
    
    init(
      color: CGColor,
      blendMode: CGBlendMode,
      width: CGFloat = 4.0,
      lineCap: CGLineCap = .butt,
      points: [CGPoint]
    ) {
      self.color = color
      self.blendMode = blendMode
      self.width = width
      self.lineCap = lineCap
      self.points = points
    }
  }
}
