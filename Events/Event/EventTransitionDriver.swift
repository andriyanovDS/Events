//
//  EventTransitionDriver.swift
//  Events
//
//  Created by Dmitry on 04.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class EventTransitionDriver: UIPercentDrivenInteractiveTransition {
  private(set) var isAnimationInProgress: Bool = false
  private(set) var isAnimationCompleted: Bool = false
  private let sharedViewOrigin: CGPoint
  private var gestureBeganOffsetY: CGFloat = CGFloat.zero
  private let dismissController: () -> Void
  
  struct Constants {
    static let closeAnimationBound: CGFloat = 35.0
  }
  
  init(
    sharedViewOrigin: CGPoint,
    dismissController: @escaping () -> Void
  ) {
    self.sharedViewOrigin = sharedViewOrigin
    self.dismissController = dismissController
  }
  
  func handlePanGesture(_ recognizer: UIPanGestureRecognizer, inside scrollView: UIScrollView) {
    if recognizer.state == .began {
      gestureBeganOffsetY = scrollView.contentOffset.y
    }
    if scrollView.contentOffset.y > 0 && !isAnimationInProgress { return }
    let translationY = recognizer.translation(in: scrollView).y - gestureBeganOffsetY
    
    if scrollView.contentOffset != CGPoint.zero {
      scrollView.contentOffset = CGPoint.zero
    }
    
    switch recognizer.state {
    case .began, .changed:
      if !isAnimationInProgress {
        isAnimationInProgress = true
        dismissController()
      }
      update(translationY / sharedViewOrigin.y)
    case .cancelled, .failed:
      isAnimationInProgress = false
      cancel()
    case .ended:
      if !isAnimationInProgress { return }
      isAnimationInProgress = false
      if translationY > Constants.closeAnimationBound {
        isAnimationCompleted = true
        finish()
        return
      }
      cancel()
    default: return
    }
  }
}
