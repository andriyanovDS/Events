//
//  Slider.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/09/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Slider {
  private let onLeft: () -> Void
  private let onRight: () -> Void
  private let getBoundsAreaSize: () -> CGSize
  private let getAnimationAreaSize: () -> CGSize
  private var translateView: UIView?
  private let disposeBag = DisposeBag()
  private var isAnimationInProgress: Bool = false

  init(
    sliderView: Observable<SliderViews>,
    onLeft: @escaping () -> Void,
    onRight: @escaping () -> Void,
    getBoundsAreaSize: @escaping () -> CGSize,
    getAnimationAreaSize: @escaping () -> CGSize
  ) {
    self.onLeft = onLeft
    self.onRight = onRight
    self.getBoundsAreaSize = getBoundsAreaSize
    self.getAnimationAreaSize = getAnimationAreaSize
    sliderView
      .subscribe(onNext: { v in
        self.translateView = v.eventView
        self.onEventViewChange(view: v.eventView)
      })
    .disposed(by: disposeBag)
  }

  private func onEventViewChange(view: UIView) {
    let swipeGestureRecognizer = UISwipeGestureRecognizer(
      target: self,
      action: #selector(handleSwipeGesture)
    )
    let panGestureRecognizer = UIPanGestureRecognizer(
      target: self,
      action: #selector(handlePanGesture)
    )
    view.addGestureRecognizer(swipeGestureRecognizer)
    view.addGestureRecognizer(panGestureRecognizer)
  }

  @objc private func handleSwipeGesture(_ recognizer: UISwipeGestureRecognizer) {
    guard recognizer.state == .ended else {
      return
    }

  }

  @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    let translation = recognizer.translation(in: translateView)
    switch recognizer.state {
    case .began, .changed:
      translateView?.transform = CGAffineTransform(translationX: translation.x, y: 0)
    case .cancelled, .ended, .failed:
      onEnd(translation: translation)
    default:
      return
    }
  }

  private func onEnd(translation: CGPoint) {
    if isAnimationInProgress == true {
      return
    }
    let size = getBoundsAreaSize()
    if abs(translation.x) >= size.width {
      let animationSize = getAnimationAreaSize()
      let direction = horizontalDirection(for: translation.x)
      isAnimationInProgress = true
      UIView.animate(
        withDuration: 200,
        animations: {
          self.translateView?.transform = CGAffineTransform(
            translationX: direction.horizontalFold(left: animationSize.width, right: -animationSize.width),
            y: 0
          )
        },
        completion: { _ in
          self.isAnimationInProgress = false
          direction.horizontalFoldL(onLeft: self.onLeft, onRight: self.onRight)
        }
      )
    } else {
      
    }
  }
}

private func horizontalDirection(for value: CGFloat) -> Direction {
  return value >= 0 ? .right : .left
}

private func verticalDirection(for value: CGFloat) -> Direction {
  return value >= 0 ? .top : .bottom
}

struct SliderViews {
  let translateView: UIView
  let eventView: UIView
}

enum Direction {
  case left, right, top, bottom

  func horizontalFold<T>(
    left: T,
    right: T
  ) -> T {
    return self == .left ? left : right
  }

  func horizontalFoldL<T>(
    onLeft: () -> T,
    onRight: () -> T
  ) -> T {
    return self == .left ? onLeft() : onRight()
  }

  func verticalFold<T>(
    top: T,
    bottom: T
  ) -> T {
    return self == .top ? top : bottom
  }

  func verticalFoldL<T>(
    onTop: () -> T,
    onBottom: () -> T
  ) -> T {
    return self == .left ? onTop() : onBottom()
  }
}
