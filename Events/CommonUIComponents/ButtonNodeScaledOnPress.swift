//
//  ButtonNodeScaledOnPress.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ButtonNodeScaleOnPress: ASButtonNode {
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
          self.view.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        } else {
          self.alpha = 1
          self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    },
      completion: { _ in onComplete() }
    )
  }
}
