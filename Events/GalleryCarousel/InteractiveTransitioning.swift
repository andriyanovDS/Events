//
//  InteractiveTransitioning.swift
//  Events
//
//  Created by Dmitry on 16.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class InteractiveTransitioning: NSObject {
  typealias CompletionHandler = () -> Void
  typealias ActiveViewProvider = () -> UIView

  var isTransitionEnabled: Bool = true
  var translationYBound: CGFloat = 75.0
  var revertAnimationDuration: TimeInterval = 0.3
  weak var delegate: InteractiveTransitioningDelegate?
  
  private let onFinish: CompletionHandler
  private var state: InteractionState = .inactive
  private let activeViewProvider: ActiveViewProvider
  private var lastTranslationY: CGFloat = 0.0
  private var feedbackGenerator: UISelectionFeedbackGenerator?
  
  init(
    view: UIView,
    onFinish: @escaping CompletionHandler,
    activeViewProvider: @escaping ActiveViewProvider
  ) {
    self.onFinish = onFinish
    self.activeViewProvider = activeViewProvider
    super.init()
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleVerticalPanGesture))
    panGestureRecognizer.delegate = self
    view.addGestureRecognizer(panGestureRecognizer)
  }
  
  @objc private func handleVerticalPanGesture(_ recognizer: UIPanGestureRecognizer) {
    guard let view = recognizer.view else { return }
    let translation = recognizer.translation(in: view)
    
    switch (recognizer.state, state) {
    case (.began, .inactive):
      let activeView = activeViewProvider()
      state = .active(animatedView: activeView)
      feedbackGenerator = UISelectionFeedbackGenerator()
      feedbackGenerator?.prepare()
    case (.changed, .active(let animatedView)):
      let translationYAbs = abs(translation.y)
      delegate?.applyActiveTranslation(translation.y, toActiveView: animatedView)
      if (lastTranslationY > translationYBound) != (translationYAbs > translationYBound) {
        feedbackGenerator?.selectionChanged()
        feedbackGenerator?.prepare()
        lastTranslationY = translationYAbs
      }
    case (.ended, .active), (.cancelled, .active):
      feedbackGenerator = nil
      lastTranslationY = 0.0
      panGestureEnded(translationY: translation.y)
    default:
      break
    }
  }
  
  private func panGestureEnded(translationY: CGFloat) {
    switch state {
    case .inactive: return
    case .active(let animatedView):
      state = .inactive
      if abs(translationY) > translationYBound {
        delegate?.applyFinishTranslation(translationY, toActiveView: animatedView)
        onFinish()
        return
      }
      
      UIView.animate(
        withDuration: revertAnimationDuration,
        animations: {
          self.delegate?.applyIdentityTranslation(toActiveView: animatedView)
        }
      )
    }
  }
}

extension InteractiveTransitioning: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard isTransitionEnabled else { return false }
    guard let view = gestureRecognizer.view else { return false }
    guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
      return false
    }
    let velocity = panGestureRecognizer.velocity(in: view)
    return abs(velocity.y) > abs(velocity.x)
  }
}

extension InteractiveTransitioning {
  enum InteractionState: Equatable {
    case inactive
    case active(animatedView: UIView)
  }
}

protocol InteractiveTransitioningDelegate: class {
  func applyActiveTranslation(_: CGFloat, toActiveView: UIView)
  func applyFinishTranslation(_: CGFloat, toActiveView: UIView)
  func applyIdentityTranslation(toActiveView: UIView)
}
