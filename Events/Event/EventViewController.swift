//
//  EventViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Promises
import AsyncDisplayKit

class EventViewController: UIViewController {
	var viewModel: EventViewModel
  let sharedImage: UIImage?
	var isInsideContextMenu: Bool
	var isCloseAnimationInProgress: Bool = false
	var contextMenuImage: UIImage? { eventView?.eventImageView.image }
	
  private var eventView: EventView?
  private let configurator: EventViewConfigurator
	private var originalViewCenter: CGPoint = CGPoint.zero

	init(
    viewModel: EventViewModel,
    sharedImage: UIImage? = nil,
    isInsideContextMenu: Bool
  ) {
    self.viewModel = viewModel
    self.sharedImage = sharedImage
    configurator = EventViewConfigurator(dataSource: viewModel)
		self.isInsideContextMenu = isInsideContextMenu
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
	
	struct Constants {
		static let maxScale: CGFloat = 0.6
		static let closeAnimationBound: CGFloat = 75.0
	}

  override func viewDidLoad() {
    super.viewDidLoad()
    if !isInsideContextMenu {
      viewModel.loadUserEvent(completion: {[unowned self] in
        self.handleUserEventDidLoad()
      })
    }
    setupView()
  }
	
	func disableSharedAnimationOnViewDisappear() {
    guard let view = eventView else { return }
		view.eventImageView.hero.id = nil
		view.eventImageView.hero.modifiers = nil
		view.scrollView.hero.modifiers = nil
		hero.modalAnimationType = .pageOut(direction: .down)
	}
	
	private func setupAppearanceAnimation(view: EventView) {
		view.eventImageView.hero.id = viewModel.event.id
		view.eventImageView.hero.modifiers = [.duration(0.4)]
		view.hero.modifiers = [.translate(y: 100), .fade, .duration(0.4)]
	}
  
  private func handleUserEventDidLoad() {
    guard let view = eventView else { return }
    view
      .setupHeaderView(configurator: configurator)
      .setupFooterView(configurator: configurator)
    
    view.headerView?.closeButton.addTarget(
      viewModel,
      action: #selector(viewModel.onClose),
      for: .touchUpInside
    )
    view.headerView?.followButton.addTarget(
      self,
      action: #selector(onPressFollowEventButton),
      for: .touchUpInside
    )
    view.footerView?.joinEventButton.addTarget(
      self,
      action: #selector(onPressJoinEventButton),
      for: .touchUpInside
    )
  }

  private func setupView() {
    let eventView = EventView(sharedImage: sharedImage)
    eventView.delegate = self
    eventView
      .setupMainInfoView(configurator: configurator)
      .setupAdditionalInfoView(configurator: configurator)
      .setupDescriptionViews(configurator: configurator)
      .setupLocationView(configurator: configurator)
      .setupAuthorView(configurator: configurator)
    
    if let url = viewModel.event.mainImageUrl {
      eventView.eventImageView.fromExternalUrl(
        url,
        withResizeTo: EventView.Constants.eventImageSize
      )
    }
    
    setupAppearanceAnimation(view: eventView)
		eventView.scrollView.panGestureRecognizer.addTarget(
			self,
			action: #selector(handleScrollViewPanGesture)
		)
    view = eventView
    self.eventView = eventView
  }

	private func scrollViewPanGestureEnded(translation: CGPoint) {
		isCloseAnimationInProgress = false
		if translation.y > Constants.closeAnimationBound {
			view.topConstraint?.constant = (view.topConstraint?.constant ?? 0) + translation.y
			view.rightConstraint?.constant = (view.rightConstraint?.constant ?? 0) + translation.x
			view.leftConstraint?.constant = (view.leftConstraint?.constant ?? 0) + translation.x
			eventView?.scrollView.hero.modifiers = nil
      viewModel.onClose()
			return
		}

		UIView.animate(
			withDuration: 0.3,
			animations: {
				self.view.center = CGPoint(
					x: self.originalViewCenter.x,
					y: self.originalViewCenter.y
				)
				self.view.transform = .identity
				self.view.layoutIfNeeded()
			}
		)
	}
	
	@objc private func handleScrollViewPanGesture(_ recognizer: UIPanGestureRecognizer) {
		guard let scrollView = eventView?.scrollView else { return }
		let translation = recognizer.translation(in: scrollView)
		switch recognizer.state {
		case .began:
			if scrollView.contentOffset.y < 0 {
				isCloseAnimationInProgress = true
				originalViewCenter = view.center
			}
		case .changed:
			if isCloseAnimationInProgress {
				let translation = recognizer.translation(in: scrollView)
				view.center = CGPoint(
					x: self.originalViewCenter.x + translation.x,
					y: self.originalViewCenter.y + translation.y
				)
				let scale = max(
					Constants.maxScale,
					1 - abs(translation.y / UIScreen.main.bounds.height * 0.5)
				)
				view.transform = CGAffineTransform(scaleX: scale, y: scale)
			}
			return
		case .ended:
			if isCloseAnimationInProgress {
				scrollViewPanGestureEnded(translation: translation)
			}
		default: return
    }
	}
	
	@objc private func onPressJoinEventButton() {
    self.eventView?.footerView?.joinButtonState = .joinInProgress
    viewModel.toggleJoinEventState {[unowned self] isJoin in
      self.eventView?.footerView?.joinButtonState = isJoin
        ? .joined
        : .notJoined
    }
	}
	
	@objc private func onPressFollowEventButton() {
    let currentValue = viewModel.userEvent?.isFollow ?? false
    eventView?.headerView?.isFollowButtonActive = !currentValue
    viewModel.toggleFollowEventState {[unowned self] isFollow in
      self.eventView?.headerView?.isFollowButtonActive = isFollow
    }
	}
}

extension EventViewController: EventViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard isCloseAnimationInProgress else { return }
    scrollView.contentOffset.y = 0
  }
}
