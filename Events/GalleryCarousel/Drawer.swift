//
//  Drawer.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class Drawer {
  typealias CompletionHandler = (UIImage?) -> Void
  
  private let canvasView = CanvasView()
  private let palette = PaletteView()
  private let containerView: UIView
  private let image: UIImage
  private let completionHandler: CompletionHandler
  private let historyActionStackView = UIStackView()
  private let footerStackView = UIStackView()
  private var contextActionButtons: [UIButton] = []
  private var activeContextAction: ContextAction = .coloredLine

  init(
    size: CGSize,
    image: UIImage,
    containerView: UIView,
    completionHandler: @escaping CompletionHandler
  ) {
    self.image = image
    self.containerView = containerView
    self.completionHandler = completionHandler
    setupCanvasView(withSize: size)
    setupGestureRecognisers()
  }
  
  deinit {
    canvasView.removeFromSuperview()
    historyActionStackView.removeFromSuperview()
    footerStackView.removeFromSuperview()
    palette.removeFromSuperview()
  }
  
  private func undo() {
    guard !canvasView.lines.isEmpty else { return }
    canvasView.lines.removeLast()
    if canvasView.lines.isEmpty {
      disableContextActions()
    }
    canvasView.setNeedsDisplay()
  }
  
  private func clearAll() {
    guard !canvasView.lines.isEmpty else { return }
    canvasView.lines.removeAll()
    canvasView.setNeedsDisplay()
  }
  
  private func disableContextActions() {
    contextActionButtons.forEach { button in
      button.alpha = 0.6
      button.isEnabled = false
    }
  }
  
  private func enableContextActions() {
    contextActionButtons.forEach { button in
      button.alpha = 1
      button.isEnabled = true
    }
  }

  private func setupGestureRecognisers() {
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    canvasView.addGestureRecognizer(panGestureRecognizer)
    canvasView.addGestureRecognizer(tapGestureRecognizer)
  }

  @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    let location = recognizer.location(in: canvasView)
    switch recognizer.state {
    case .began:
      let line = CanvasView.ColoredLine(
        color: palette.selectedColor.value.cgColor,
        blendMode: activeContextAction == .eraser
          ? .clear
          : .normal,
        points: [location]
      )
      canvasView.lines.append(line)
    case .changed:
      let lastIndex = canvasView.lines.endIndex - 1
      canvasView.lines[lastIndex].points.append(location)
      enableContextActions()
      canvasView.setNeedsDisplay()
    default: return
    }
  }

  @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
    guard recognizer.state == .ended else { return }
    let location = recognizer.location(in: canvasView)
    let endPoint = CGPoint(x: location.x, y: location.y + 4)
    let line = CanvasView.ColoredLine(
      color: palette.selectedColor.value.cgColor,
      blendMode: activeContextAction == .eraser
        ? .clear
        : .normal,
      lineCap: .round,
      points: [location, endPoint]
    )
    canvasView.lines.append(line)
    canvasView.setNeedsDisplay()
  }
  
  private func saveContext() {
    if canvasView.lines.isEmpty {
      completionHandler(image)
      return
    }
    UIGraphicsBeginImageContextWithOptions(canvasView.frame.size, true, 0)
    image.draw(in: canvasView.bounds)
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    canvasView.layer.render(in: context)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    completionHandler(image)
  }
  
  private func endEditing() {
    completionHandler(nil)
  }
}

extension Drawer {
  private func setupCanvasView(withSize size: CGSize) {
    canvasView.backgroundColor = .clear
    setupHistoryActions()
    setupFooterView()
    
    containerView.sv([canvasView, palette])
    canvasView
      .height(size.height)
      .width(size.width)
      .centerInContainer()
    palette.CenterX == containerView.CenterX
    palette
      .width(palette.totalWidth)
      .height(palette.totalHeight)
      .Bottom == footerStackView.Top - 30
  }
  
  private func setupHistoryActions() {
    historyActionStackView.axis = .horizontal
    historyActionStackView.alignment = .center
    historyActionStackView.distribution = .equalCentering
    
    let undoButton = GenericButton(value: HistoryAction.undo)
    let undoIcon = Icon(material: "undo", sfSymbol: "arrow.turn.up.left")
    undoButton.setIcon(undoIcon, size: 30, color: .fontLabelInverted)
    undoButton.onTouch = {[unowned self] _ in
      self.undo()
    }
    
    let clearButton = GenericButton(value: HistoryAction.clear)
    styleText(
      button: clearButton,
      text: "Clear all",
      size: 18,
      color: .fontLabelInverted,
      style: .medium
    )
    clearButton.onTouch = {[unowned self] _ in
      self.clearAll()
    }
    
    undoButton.size(44)
    historyActionStackView.addArrangedSubview(undoButton)
    historyActionStackView.addArrangedSubview(clearButton)
    contextActionButtons.append(contentsOf: [undoButton, clearButton])
    disableContextActions()
    containerView.sv(historyActionStackView)
    historyActionStackView.left(10).right(10).Top == containerView.safeAreaLayoutGuide.Top + 20
  }
  
  private func handleContextAction(_ action: ContextAction) {
    switch action {
    case .cancel:
      endEditing()
    case .coloredLine, .eraser:
      activeContextAction = action
      for button in footerStackView.arrangedSubviews {
        guard let actionButton = button as? GenericButton<ContextAction> else {
          continue
        }
        actionButton.backgroundColor = actionButton.value == action
          ? .grayButtonBackground
          : .clear
      }
      return
    case .save:
      saveContext()
    }
  }
  
  private func setupFooterView() {
    footerStackView.axis = .horizontal
    footerStackView.alignment = .center
    footerStackView.distribution = .equalSpacing
    footerStackView.spacing = 10
    
    for action in ContextAction.allCases {
      let button = GenericButton(value: action)
      button.backgroundColor = activeContextAction == action
        ? .grayButtonBackground
        : .clear
      button.layer.cornerRadius = 6
      button.setIcon(action.icon, size: 35, color: .fontLabelInverted)
      button.size(44)
      button.onTouch = {[unowned self] action in
        self.handleContextAction(action)
      }
      footerStackView.addArrangedSubview(button)
    }
    containerView.sv(footerStackView)
    footerStackView.left(20).right(20).Bottom == containerView.safeAreaLayoutGuide.Bottom - 10
  }
}

extension Drawer {
  enum HistoryAction {
    case undo
    case clear
  }
  
  enum ContextAction: CaseIterable, Equatable {
    case cancel
    case coloredLine
    case eraser
    case save
    
    var icon: Icon {
      switch self {
      case .cancel:
        return Icon(material: "highlight.off", sfSymbol: "xmark.circle")
      case .coloredLine:
        return Icon(material: "brush")
      case .eraser:
        return Icon(material: "lens")
      case .save:
        return Icon(material: "check.circle", sfSymbol: "checkmark.circle")
      }
    }
  }
}
