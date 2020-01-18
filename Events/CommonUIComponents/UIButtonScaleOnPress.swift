//
//  UIButtonScaleOnPress.swift
//  Events
//
//  Created by Дмитрий Андриянов on 17/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class UIButtonScaleOnPress: UIButton {
  var uniqueData: Any?
  private let animationDuration = 0.2
  private var isAnimationInProgress = false

  override var isHighlighted: Bool {
    willSet (nextValue) {
      if !nextValue || isAnimationInProgress {
        return
      }
      isAnimationInProgress = true
      startAnimation(isHiglighted: true, onComplete: {
        self.startAnimation(isHiglighted: false, onComplete: {
          self.isAnimationInProgress = false
        })
      })
    }
  }
  private func startAnimation(isHiglighted: Bool, onComplete: @escaping () -> Void) {
    UIView.animate(
      withDuration: animationDuration,
      delay: 0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 0.75,
      options: .allowUserInteraction,
      animations: {
        if isHiglighted {
          self.alpha = 0.7
          self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        } else {
          self.alpha = 1
          self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    },
      completion: { _ in onComplete() }
    )
  }
}
