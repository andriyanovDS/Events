//
//  EventViewControllerTransitionDelegate.swift
//  Events
//
//  Created by Dmitry on 02.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class EventViewControllerTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
  private let dismissCompletionHandler: EventDismissAnimationController.DismissCompletionHandler
  private let transitionDriver: EventTransitionDriver
  private let sharedCardInfo: SharedEventCardInfo!
  
  init(
    sharedCardInfo: SharedEventCardInfo,
    transitionDriver: EventTransitionDriver,
    dismissCompletionHandler: @escaping EventDismissAnimationController.DismissCompletionHandler
  ) {
    self.sharedCardInfo = sharedCardInfo
    self.transitionDriver = transitionDriver
    self.dismissCompletionHandler = dismissCompletionHandler
  }
  
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return EventPresentationAnimationController(sharedCardInfo: sharedCardInfo)
  }
  
  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return EventDismissAnimationController(
      sharedCardInfo: sharedCardInfo,
      transitionDriver: transitionDriver,
      dismissCompletionHandler: dismissCompletionHandler
    )
  }
  
  func interactionControllerForDismissal(
    using animator: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    return transitionDriver.isAnimationInProgress
      ? transitionDriver
      : nil
  }
}

struct SharedEventCardInfo {
  let frame: CGRect
  let origin: CGPoint
  let imageHeight: CGFloat
  let containerView: UIView
}
