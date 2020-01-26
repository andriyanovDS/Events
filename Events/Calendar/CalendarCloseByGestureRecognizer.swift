//
//  CalendarSwipe.swift
//  Events
//
//  Created by Дмитрий Андриянов on 25/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class CalendarCloseByGestureRecognizer {
  private let parentView: UIView
  private let animatedView: UIView
  private let onClose: () -> Void
  private let gestureBounds: CGRect

  private var lastTransitionY: CGFloat = CGFloat.zero
  private var isGestureActive: Bool = false
  private var originalViewCenter: CGPoint = CGPoint.zero
  private var feedbackGenerator: UISelectionFeedbackGenerator?

  init(
    parentView: UIView,
    animatedView: UIView,
    gestureBounds: CGRect,
    onClose: @escaping () -> Void
  ) {
    self.parentView = parentView
    self.animatedView = animatedView
    self.onClose = onClose
    self.gestureBounds = gestureBounds

    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
    animatedView.addGestureRecognizer(panRecognizer)
  }

  private func panGestureEnded(translation: CGPoint) {
    if !isGestureActive { return }

    isGestureActive = false
    if translation.y > gestureBounds.height {

      animatedView.topConstraint?.constant = (animatedView.topConstraint?.constant ?? 0) + translation.y
      animatedView.rightConstraint?.constant = (animatedView.rightConstraint?.constant ?? 0) + translation.x
      animatedView.leftConstraint?.constant = (animatedView.leftConstraint?.constant ?? 0) + translation.x

      onClose()
      return
    }

    UIView.animate(
      withDuration: 0.3,
      animations: {
        self.animatedView.center = CGPoint(
          x: self.originalViewCenter.x,
          y: self.originalViewCenter.y
        )
        self.animatedView.layoutIfNeeded()
      }
    )
  }

  @objc private func panGestureHandler(_ recognizer: UIPanGestureRecognizer) {
    let state = recognizer.state
    let translation = recognizer.translation(in: parentView)

    defer {
      lastTransitionY = translation.y
    }

    switch state {
    case .began:
      isGestureActive = true
      originalViewCenter = animatedView.center
      feedbackGenerator = UISelectionFeedbackGenerator()
      feedbackGenerator?.prepare()
    case .changed:
      animatedView.center = CGPoint(
        x: self.originalViewCenter.x + translation.x,
        y: self.originalViewCenter.y + translation.y
      )
      let boundsYPosition = gestureBounds.height
      if
        (lastTransitionY > boundsYPosition && translation.y < boundsYPosition)
        || (translation.y > gestureBounds.height && lastTransitionY < boundsYPosition)
      {
        feedbackGenerator?.selectionChanged()
        feedbackGenerator?.prepare()
      }
    case .cancelled, .ended, .failed:
      feedbackGenerator = nil
      panGestureEnded(translation: translation)
    default:
      break
    }
  }
}
