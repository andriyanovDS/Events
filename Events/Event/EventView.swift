//
//  EventNode.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import Hero
import Promises
import AVFoundation

class EventView: UIView {
  let eventImageView = UIImageView()
	let scrollView = UIScrollView()
  weak var delegate: EventViewDelegate?
	private(set) var footerView: EventFooterView?
  private(set) var headerView: EventHeaderActionsView?
	private let contentView = UIView()
  private let infoStackView = UIStackView()
	private let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear)
	private var safeAreaTopPadding: CGFloat {
		UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
	}
  
  struct Constants {
    static let actionsStackHeight: CGFloat = 60.0
    static let eventImageSize: CGSize = CGSize(
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height * 0.3
    )
    static let actionStackAnimationDelayFactor: CGFloat =
      1 - Constants.actionsStackHeight / Constants.eventImageSize.height
  }

  init(sharedImage: UIImage?) {
    super.init(frame: CGRect.zero)
		scrollView.delegate = self
    setupView(sharedImage: sharedImage)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
	
	deinit {
		animator.stopAnimation(false)
		if animator.state == .stopped {
			animator.finishAnimation(at: .current)
		}
  }
  
  @discardableResult
  func setupHeaderView(configurator: EventViewConfigurator) -> EventView {
    let view = EventHeaderActionsView()
    configurator.configureHeaderView(view)
    sv(view)
    headerView = view
    view
      .top(-safeAreaTopPadding)
      .left(0)
      .right(0)
      .height(Constants.actionsStackHeight)
    return self
  }
  
  @discardableResult
  func setupFooterView(configurator: EventViewConfigurator) -> EventView {
    let view = EventFooterView(pricePerPerson: nil)
    configurator.configureFooterView(view)
    sv(view)
    footerView = view
    footerView?.left(0).right(0).bottom(0)
    return self
  }
  
  @discardableResult
  func setupMainInfoView(configurator: EventViewConfigurator) -> EventView {
    let view = EventMainInfoView()
    configurator.configureMainInfoView(view)
    infoStackView.addArrangedSubview(view)
    return self
  }
  
  @discardableResult
  func setupAdditionalInfoView(configurator: EventViewConfigurator) -> EventView {
    let view = EventAdditionalInfoView()
    configurator.configureAdditionalInfoView(view)
    infoStackView.addArrangedSubview(view)
    return self
  }
  
  @discardableResult
  func setupDescriptionViews(configurator: EventViewConfigurator) -> EventView {
    for index in 0...configurator.descriptionCount - 1 {
      let view = EventDescriptionView(isExpanded: index == 0)
      view.delegate = self
      configurator.configureDescriptionView(view, at: index)
      if index == 0, let lastView = infoStackView.arrangedSubviews.last {
        infoStackView.setCustomSpacing(25, after: lastView)
      }
      infoStackView.addArrangedSubview(view)
    }
    return self
  }
  
  @discardableResult
  func setupLocationView(configurator: EventViewConfigurator) -> EventView {
    let view = EventLocationView()
    configurator.configureLocationView(view)
    infoStackView.addArrangedSubview(view)
    return self
  }
  
  @discardableResult
  func setupAuthorView(configurator: EventViewConfigurator) -> EventView {
    let view = EventAuthorView()
    configurator.configureAuthorView(view)
    infoStackView.addArrangedSubview(view)
    return self
  }

  private func setupView(sharedImage: UIImage?) {
		backgroundColor = .background
		isOpaque = false
		layer.cornerRadius = 15
		clipsToBounds = true
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
    eventImageView.image = sharedImage
    eventImageView.clipsToBounds = true
		eventImageView.contentMode = .scaleAspectFill
    
		setupAnimations()
    infoStackView.axis = .vertical
    infoStackView.spacing = 8
    infoStackView.distribution = .fill
		
    contentView.sv(eventImageView, infoStackView)
    scrollView.sv(contentView)
    sv(scrollView)
    setupConstraints()
  }
	
	private func setupAnimations() {
		animator.addAnimations({[unowned self] in
      self.headerView?.backgroundView.alpha = 1
		}, delayFactor: Constants.actionStackAnimationDelayFactor)
	}

  private func setupConstraints() {
		scrollView
			.top(0)
		  .left(0)
			.right(0)
			.bottom(0)
			.Width == Width
		contentView.fillContainer().width(100%)
    eventImageView
      .top(0)
      .left(0)
      .width(Constants.eventImageSize.width)
      .height(Constants.eventImageSize.height)
    infoStackView.left(15).right(15).bottom(0).Top == eventImageView.Bottom + 25
  }
}

extension EventView: EventDescriptionDelegate {
  func scrollToView(_ view: UIView) {
		let scrollTo = infoStackView.convert(view.frame.origin, to: scrollView).y - 150.0
		scrollView.setContentOffset(CGPoint(
			x: 0,
			y: scrollTo
		), animated: false)
  }
}

extension EventView: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
    delegate?.scrollViewDidScroll(scrollView)

    guard let headerView = self.headerView else { return }
		let offsetY = scrollView.contentOffset.y
    let relativeDistance = abs(offsetY / Constants.eventImageSize.height)
		let fractionComplete = min(max(0, relativeDistance), 1)
		if animator.fractionComplete == fractionComplete { return }
		if animator.fractionComplete < Constants.actionStackAnimationDelayFactor,
			fractionComplete >= Constants.actionStackAnimationDelayFactor {
      headerView.isBackgroundOpaque = true
		} else if animator.fractionComplete > Constants.actionStackAnimationDelayFactor,
			fractionComplete <= Constants.actionStackAnimationDelayFactor {
			headerView.isBackgroundOpaque = false
		}
		animator.fractionComplete = fractionComplete
	}
}

protocol EventViewDelegate: class {
  func scrollViewDidScroll(_: UIScrollView)
}
