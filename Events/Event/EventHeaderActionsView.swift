//
//  EventHeaderActionsView.swift
//  Events
//
//  Created by Dmitry on 19.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class EventHeaderActionsView: UIView {
  let followButton = UIButtonScaleOnPress()
  let closeButton = UIButtonScaleOnPress()
  let backgroundView = UIView()
  private let stackView = UIStackView()
  var isBackgroundOpaque: Bool = false {
    didSet { isBackgroundOpaqueDidChanged() }
  }
  var isFollowButtonActive: Bool = false {
    didSet { updateFollowButtonState() }
  }
  
  init() {
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func isBackgroundOpaqueDidChanged() {
    let color: UIColor = isBackgroundOpaque
      ? .fontLabel
      : .fontLabelInverted
    closeButton.tintColor = color
    if !isFollowButtonActive {
      followButton.tintColor = color
    }
  }
  
  func updateFollowButtonState() {
    if isFollowButtonActive {
      followButton.tintColor = .destructive
      return
    }
    followButton.tintColor = isBackgroundOpaque
      ? .fontLabel
      : .fontLabelInverted
  }
  
  private func setupView() {
    backgroundView.alpha = 0
    backgroundView.backgroundColor = .background
    stackView.axis = .horizontal
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(
      top: 0,
      left: 20,
      bottom: 0,
      right: 20
    )
    
    let followIcon = Icon(material: "favorite", sfSymbol: "heart.fill")
    followButton.setIcon(followIcon, size: 30, color: .fontLabelInverted)
    followButton.size(44)
    
    let closeIcon = Icon(material: "close", sfSymbol: "xmark")
    closeButton.setIcon(closeIcon, size: 30, color: .fontLabelInverted)
    closeButton.size(44)
    
    stackView.addArrangedSubview(followButton)
    stackView.addArrangedSubview(closeButton)
    
    sv([backgroundView, stackView])
    stackView.fillContainer()
    backgroundView.fillContainer()
  }
}
