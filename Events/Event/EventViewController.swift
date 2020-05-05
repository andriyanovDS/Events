//
//  EventViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Promises
import Stevia

class EventViewController: UIViewController {
	var viewModel: EventViewModel
  let sharedImage: UIImage?
	var isInsideContextMenu: Bool
  var transitionDriver: EventTransitionDriver?
	
  private var eventView: EventView?
  private let configurator: EventViewConfigurator

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

  override func viewDidLoad() {
    super.viewDidLoad()
    if !isInsideContextMenu {
      viewModel.loadUserEvent()
      viewModel.loadAuthor()
    }
    setupView()
  }
	
	func disableSharedAnimationOnViewDisappear() {
    guard let view = eventView else { return }
		view.scrollView.hero.modifiers = nil
		hero.modalAnimationType = .pageOut(direction: .down)
	}

  private func setupView() {
    let eventView = EventView()
    eventView.delegate = self
    eventView
      .setupCardView(configurator: configurator, sharedImage: sharedImage)
      .setupAdditionalInfoView(configurator: configurator)
      .setupDescriptionViews(configurator: configurator)
      .setupLocationView(configurator: configurator)
    
    if let url = viewModel.event.mainImageUrl {
      eventView.cardView.imageView.fromExternalUrl(
        url,
        withResizeTo: EventView.Constants.eventImageSize
      )
    }
    
    eventView.scrollView.panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture))
    
    view = eventView
    self.eventView = eventView
  }
	
	@objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
    guard let eventView = eventView else { return }
		guard let driver = transitionDriver else { return }
    driver.handlePanGesture(recognizer, inside: eventView.scrollView)
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
  
  @objc private func onClose() {
    viewModel.onClose()
  }
}

extension EventViewController: EventViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard transitionDriver != nil else { return }
    let isBounceAvailable = scrollView.contentOffset.y >= 30
    let isBounceTurned = scrollView.bounces
    guard isBounceAvailable != isBounceTurned else { return }
    scrollView.alwaysBounceVertical = isBounceAvailable
    scrollView.bounces = isBounceAvailable
  }
}

extension EventViewController: EventViewModelDelegate {
  func viewModelDidLoadAuthor(_ viewModel: EventViewModel) {
    eventView?.setupAuthorView(configurator: configurator)
  }
  
  func viewModelDidLoadUserEventState(_: EventViewModel) {
    guard let view = eventView else { return }
    view
      .setupHeaderView(configurator: configurator)
      .setupFooterView(configurator: configurator)

    view.headerView?.closeButton.addTarget(
      self,
      action: #selector(onClose),
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
}
