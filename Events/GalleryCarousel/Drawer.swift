//
//  Drawer.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import AVFoundation

class Drawer {
  typealias CompletionHandler = () -> Void
  
  private let canvasView = CanvasView()
  private let palette = PaletteView()
  private let containerView: GalleryCarouselView
  private let image: UIImage
  private let imageView: UIImageView
  private let originImageViewSize: CGSize
  private let completionHandler: CompletionHandler
  private let historyActionView = UIView()
  private let footerStackView = UIStackView()
  private var contextActionButtons: [UIButton] = []
  private var activeContextAction: ContextAction = .coloredLine

  init?(
    imageView: UIImageView,
    containerView: GalleryCarouselView,
    completionHandler: @escaping CompletionHandler
  ) {
    guard let image = imageView.image else {
      return nil
    }
    self.image = image
    self.imageView = imageView
    self.containerView = containerView
    self.completionHandler = completionHandler
    self.originImageViewSize = imageView.bounds.size
    setupCanvasView(withSize: imageView.frame.size)
    setupGestureRecognisers()
    updateImageViewSizeIfNeeded()
    containerView.changeAccessoryViewsVisibility(isHidden: true)
  }
  
  deinit {
    canvasView.removeFromSuperview()
    historyActionView.removeFromSuperview()
    footerStackView.removeFromSuperview()
    palette.removeFromSuperview()
  }
  
  private func updateImageViewSizeIfNeeded() {
    containerView.layoutIfNeeded()
    let height = footerStackView.frame.minY - historyActionView.frame.maxY - 20
    let rect = CGRect(x: 0, y: 0, width: containerView.frame.width, height: height)
    let size = AVMakeRect(aspectRatio: image.size, insideRect: rect)
    guard height.rounded(.down) < imageView.bounds.height.rounded(.down) else {
      return
    }
    
    UIView.animate(withDuration: 0.4, animations: {
      self.imageView.widthConstraint?.constant = size.width
      self.imageView.heightConstraint?.constant = size.height
      self.imageView.setNeedsLayout()
      self.imageView.superview?.layoutIfNeeded()
      
      self.canvasView.heightConstraint?.constant = size.height
      self.containerView.layoutIfNeeded()
    })
  }
  
  private func dismiss() {
    palette.performDisappearAnimation(duration: 0.2)
    containerView.changeAccessoryViewsVisibility(isHidden: false)
    UIView.animate(withDuration: 0.2, animations: {
      self.footerStackView.alpha = 0
      self.historyActionView.alpha = 0
      
      if self.originImageViewSize.height > self.imageView.bounds.height {
        self.imageView.heightConstraint?.constant = self.originImageViewSize.height
        self.imageView.superview?.layoutIfNeeded()
      }
    }, completion: {[weak self] _ in
      self?.completionHandler()
    })
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
      dismiss()
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
    canvasView.removeFromSuperview()
    imageView.image = image
    dismiss()
  }
}

extension Drawer {
  private func setupCanvasView(withSize size: CGSize) {
    canvasView.backgroundColor = .clear
    
    containerView.sv([canvasView, palette])
    setupHistoryActions()
    setupFooterView()
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
    historyActionView.backgroundColor = UIColor.backgroundInverted.withAlphaComponent(0.7)
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .equalCentering
    
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
    stackView.addArrangedSubview(undoButton)
    stackView.addArrangedSubview(clearButton)
    contextActionButtons.append(contentsOf: [undoButton, clearButton])
    disableContextActions()
    historyActionView.sv(stackView)
    containerView.sv(historyActionView)
    historyActionView.top(0).left(0).right(0)
    let insetTop = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    stackView.left(10).right(10).top(insetTop + 10).bottom(0)
  }
  
  private func handleContextAction(_ action: ContextAction) {
    switch action {
    case .cancel:
      dismiss()
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
