//
//  EventDismissAnimationController.swift
//  Events
//
//  Created by Dmitry on 03.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class EventDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  typealias DismissCompletionHandler = () -> Void
  
  private let dismissCompletionHandler: DismissCompletionHandler
  private let sharedCardInfo: SharedEventCardInfo
  private let transitionDriver: EventTransitionDriver
  
  init(
    sharedCardInfo: SharedEventCardInfo,
    transitionDriver: EventTransitionDriver,
    dismissCompletionHandler: @escaping DismissCompletionHandler
  ) {
    self.sharedCardInfo = sharedCardInfo
    self.transitionDriver = transitionDriver
    self.dismissCompletionHandler = dismissCompletionHandler
  }
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  private func copyShadow(from view: UIView, to destinationView: UIView) {
    let copiedLayer = view.layer
    destinationView.layer.shadowRadius = copiedLayer.shadowRadius
    destinationView.layer.shadowOpacity = copiedLayer.shadowOpacity
    destinationView.layer.shadowColor = copiedLayer.shadowColor
    destinationView.layer.shadowOffset = copiedLayer.shadowOffset
  }
  
  private func clearShadow(in view: UIView) {
    view.layer.shadowRadius = 0
    view.layer.shadowOpacity = 1
    view.layer.shadowColor = UIColor.clear.cgColor
    view.layer.shadowOffset = CGSize.zero
  }
  
  private func setConstraints(
    contentView: UIView,
    cardImageView: UIView,
    finalFrame: CGRect,
    finalOrigin: CGPoint,
    finalImageHeight: CGFloat
  ) {
    contentView.topConstraint?.constant = finalOrigin.y
    contentView.leftConstraint?.constant = finalOrigin.x
    contentView.widthConstraint?.constant = finalFrame.width
    contentView.heightConstraint?.constant = finalFrame.height
    cardImageView.widthConstraint?.constant = finalFrame.width
    cardImageView.heightConstraint?.constant = finalImageHeight
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
    
    guard let fromView = fromViewController.view as? EventView else { return }
    if let cardView: EventCardView = EventPresentationAnimationController.findCardView(inside: [fromView]) {
      let containerView = transitionContext.containerView
      let cellShadowView: UIView = sharedCardInfo.containerView
      copyShadow(from: cellShadowView, to: fromView)
      cellShadowView.isHidden = true
      fromView.footerView?.isHidden = true
      
      let origin = sharedCardInfo.origin
      let finalFrame = sharedCardInfo.frame
      let initialFrame = fromView.frame
      let initialImageHeight = cardView.imageView.frame.height
      let duration = transitionDuration(using: transitionContext)
    
      UIView.animate(
        withDuration: duration,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0,
        animations: {
          fromView.headerView?.alpha = 0
          self.setConstraints(
            contentView: fromView,
            cardImageView: cardView.imageView,
            finalFrame: finalFrame,
            finalOrigin: origin,
            finalImageHeight: self.sharedCardInfo.imageHeight
          )
          containerView.layoutIfNeeded()
        },
        completion: { _ in
          cellShadowView.isHidden = false
          if transitionContext.transitionWasCancelled {
            self.clearShadow(in: fromView)
            fromView.footerView?.isHidden = false
            self.setConstraints(
              contentView: fromView,
              cardImageView: cardView.imageView,
              finalFrame: initialFrame,
              finalOrigin: CGPoint.zero,
              finalImageHeight: initialImageHeight
            )
            containerView.layoutIfNeeded()
          } else {
            self.dismissCompletionHandler()
          }
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
      )
    }
  }
}
