//
//  EventPresentationAnimationController.swift
//  Events
//
//  Created by Dmitry on 02.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EventPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  private let sharedCardInfo: SharedEventCardInfo
  
  init(sharedCardInfo: SharedEventCardInfo) {
    self.sharedCardInfo = sharedCardInfo
  }
  
  static func findCardView<T: UIView>(inside candidates: [UIView]) -> T? {
    var subviews: [UIView?] = candidates
    for index in 0..<subviews.count {
      if let view = candidates[index] as? T {
        return view
      }
      subviews[index] = nil
      subviews.append(contentsOf: candidates[index].subviews)
    }
    if subviews.isEmpty { return nil }
    if let views = Array(subviews[candidates.count..<subviews.endIndex]) as? [UIView] {
      return findCardView(inside: views)
    }
    return nil
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 1
  }
  
  private func setupDestinationView(
    _ destinationView: UIView,
    containerView: UIView,
    cardView: EventCardView
  ) {
    let origin = sharedCardInfo.origin
    let frame = sharedCardInfo.frame
    containerView.sv(destinationView)
    destinationView
      .top(origin.y)
      .left(origin.x)
      .width(frame.width)
      .height(frame.height)
    cardView.imageView.heightConstraint?.constant = sharedCardInfo.imageHeight
    cardView.imageView.width(frame.width)
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let eventViewController = transitionContext.viewController(forKey: .to) else { return }
    
    let destinationView = eventViewController.view!
    destinationView.setNeedsLayout()
    destinationView.layoutIfNeeded()
    if let cardView: EventCardView = EventPresentationAnimationController.findCardView(inside: [destinationView]) {
      let containerView = transitionContext.containerView
      let finalFrame = transitionContext.finalFrame(for: eventViewController)
      let cardViewImageViewHeight = cardView.imageView.frame.height
      
      setupDestinationView(
        destinationView,
        containerView: containerView,
        cardView: cardView
      )
      containerView.layoutIfNeeded()
     
      UIView.animate(
        withDuration: transitionDuration(using: transitionContext),
        delay: 0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 0,
        options: .curveEaseOut,
        animations: {
          destinationView.leftConstraint?.constant = 0
          destinationView.topConstraint?.constant = 0
          destinationView.heightConstraint?.constant = finalFrame.height
          destinationView.widthConstraint?.constant = finalFrame.width
          cardView.widthConstraint?.constant = finalFrame.width
          cardView.imageView.heightConstraint?.constant = cardViewImageViewHeight
          containerView.layoutIfNeeded()
        },
        completion: { _ in
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
      )
    }
  }
}
