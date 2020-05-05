//
//  EventAnimationController.swift
//  Events
//
//  Created by Dmitry on 02.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EventPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  private let sharedView: EventCardView
  
  init(sharedView: EventCardView) {
    self.sharedView = sharedView
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 1.5
  }
  
  private func setupAnimatedView(
    _ animatedView: UIView,
    containerView: UIView,
    destinationView: UIView,
    cardView: EventCardView,
    sharedViewOrigin: CGPoint
  ) {
    animatedView.sv(destinationView)
    containerView.sv(animatedView)
    
    animatedView.width(sharedView.frame.width)
    animatedView.height(sharedView.frame.height - 30)
    animatedView.top(sharedViewOrigin.y)
    animatedView.left(sharedViewOrigin.x)
    destinationView.fillContainer()
    destinationView.widthConstraint?.constant = sharedView.frame.width
    destinationView.Height == animatedView.Height
    cardView.imageView.heightConstraint?.constant = sharedView.imageView.frame.height
    cardView.imageView.Width == animatedView.Width
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let fromViewController = transitionContext.viewController(forKey: .from),
      let eventViewController = transitionContext.viewController(forKey: .to) else { return }
    
    let destinationView = eventViewController.view!
    destinationView.setNeedsLayout()
    destinationView.layoutIfNeeded()
    let destinationCardView: EventCardView? = findCardView(inside: [eventViewController.view])
    if let cardView = destinationCardView {
      let containerView = transitionContext.containerView
      let origin = sharedView.superview!.convert(sharedView.frame.origin, to: fromViewController.view)
      let finalFrame = transitionContext.finalFrame(for: eventViewController)
    
      let animationContentView = UIView()
      setupAnimatedView(
        animationContentView,
        containerView: containerView,
        destinationView: destinationView,
        cardView: cardView,
        sharedViewOrigin: origin
      )
      containerView.layoutIfNeeded()
     
      UIView.animate(
        withDuration: transitionDuration(using: transitionContext),
        delay: 0,
        usingSpringWithDamping: 0.6,
        initialSpringVelocity: 1,
        options: .curveEaseOut,
        animations: {
          animationContentView.leftConstraint?.constant = 0
          animationContentView.topConstraint?.constant = 0
          animationContentView.widthConstraint?.constant = finalFrame.width
          animationContentView.heightConstraint?.constant = finalFrame.height
          destinationView.widthConstraint?.constant = finalFrame.width
          containerView.layoutIfNeeded()
        },
        completion: { _ in
          containerView.sv(eventViewController.view)
          destinationView.fillContainer()
          animationContentView.removeFromSuperview()
          transitionContext.completeTransition(true)
        }
      )
    }
  }
  
  private func findCardView<T: UIView>(inside candidates: [UIView]) -> T? {
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
}
