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
  unowned var viewModel: EventViewModel
  let sharedImage: UIImage?
  private var eventView: EventView?
	private var originalViewCenter: CGPoint = CGPoint.zero

  init(viewModel: EventViewModel, sharedImage: UIImage?) {
    self.viewModel = viewModel
    self.sharedImage = sharedImage
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
	
	enum FollowEventState {
		case followed, notFollowed, inProgress
		
		var iconColor: UIColor {
			switch self {
			case .followed:
				return .lightRed()
			case .notFollowed:
				return .white
			case .inProgress:
				return .clear
			}
		}
		
		var iconName: String? {
			switch self {
			case .followed:
				return String.fontMaterialIcon("favorite")
			case .notFollowed:
				return String.fontMaterialIcon("favorite.border")
			case .inProgress:
				return nil
			}
		}
		
		static func fromBool(_ value: Bool) -> Self {
			value ? .followed : .notFollowed
		}
	}
	
	struct Constants {
		static let maxScale: CGFloat = 0.6
		static let closeAnimationBound: CGFloat = 75.0
	}

  override func viewDidLoad() {
    super.viewDidLoad()
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
		view.scrollView.hero.modifiers = [.translate(y: 100), .fade, .duration(0.4)]
	}

  private func setupView() {
    let eventView = EventView(sharedImage: sharedImage, dataSource: viewModel)
    setupAppearanceAnimation(view: eventView)
    eventView.closeButtonView.addTarget(self, action: #selector(onClose), for: .touchUpInside)
		eventView.footerView.joinEventButton.addTarget(
			self,
			action: #selector(onPressJoinEventButton),
			for: .touchUpInside
		)
		eventView.followButtonView.addTarget(
			self,
			action: #selector(onPressFollowEventButton),
			for: .touchUpInside
		)
		eventView.scrollView.panGestureRecognizer.addTarget(
			self,
			action: #selector(handleScrollViewPanGesture)
		)
    view = eventView
    self.eventView = eventView
		viewModel.loadUserEvent()
			.then {[weak self] userEvent in
				self?.handleLoadedUserEvent(userEvent)
			}
  }
	
	private func handleLoadedUserEvent(_ userEvent: UserEvent) {
		let followState = FollowEventState.fromBool(
			userEvent.isFollow
		)
		viewModel.userEvent = userEvent
		viewModel.userFollowEventState = followState
		eventView?.followButtonView.setTitleColor(followState.iconColor, for: .normal)
		eventView?.followButtonView.setTitle(followState.iconName, for: .normal)
		eventView?.footerView.joinButtonState = userEvent.isJoin
			? .joined
			: .notJoined
	}
	
	private func scrollViewPanGestureEnded(translation: CGPoint) {
		viewModel.isCloseAnimationInProgress = false
		if translation.y > Constants.closeAnimationBound {
			
			view.topConstraint?.constant = (view.topConstraint?.constant ?? 0) + translation.y
			view.rightConstraint?.constant = (view.rightConstraint?.constant ?? 0) + translation.x
			view.leftConstraint?.constant = (view.leftConstraint?.constant ?? 0) + translation.x
			eventView?.scrollView.hero.modifiers = nil
			onClose()
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
			if scrollView.contentOffset.y + view.safeAreaInsets.top < 0 {
				viewModel.isCloseAnimationInProgress = true
				originalViewCenter = view.center
			}
		case .changed:
			if viewModel.isCloseAnimationInProgress {
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
			if viewModel.isCloseAnimationInProgress {
				scrollViewPanGestureEnded(translation: translation)
			}
		default:
			return
		}
	}
	
	@objc private func onPressJoinEventButton() {
		let currentButtonState = eventView!.footerView.joinButtonState
		guard currentButtonState != .joinInProgress else {
			return
		}
		eventView?.footerView.joinButtonState = .joinInProgress
		let value = currentButtonState != .joined
		viewModel.updateUserEvent(value: ["isJoin": value])
			.then {[weak self] _ in
				self?.viewModel.userEvent?.isJoin = value
				self?.eventView?.footerView.joinButtonState = value
					? .joined
					: .notJoined
			}
			.catch {[weak self] error in
				print("Failed to set join event \(error)")
				self?.eventView?.footerView.joinButtonState = currentButtonState
			}
	}
	
	@objc private func onPressFollowEventButton() {
		let currentState = viewModel.userFollowEventState
		if viewModel.userFollowEventState == .inProgress { return }
		viewModel.userFollowEventState = .inProgress
		let nextState: FollowEventState = currentState == .followed
			? .notFollowed
			: .followed
		eventView?.followButtonView.setTitleColor(nextState.iconColor, for: .normal)
		eventView?.followButtonView.setTitle(nextState.iconName, for: .normal)
		let value = nextState == .followed
		viewModel.updateUserEvent(value: ["isFollow": value])
			.then {[weak self] _ in
				self?.viewModel.userEvent?.isFollow = value
				self?.viewModel.userFollowEventState = nextState
			}
			.catch {[weak self] error in
				print("Failed to set join event \(error)")
				self?.viewModel.userFollowEventState = currentState
				self?.eventView?.followButtonView.setTitleColor(currentState.iconColor, for: .normal)
				self?.eventView?.followButtonView.setTitle(currentState.iconName, for: .normal)
			}
	}

  @objc private func onClose() {
    viewModel.onClose()
  }
}
