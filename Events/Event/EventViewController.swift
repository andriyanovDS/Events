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

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }

  private func setupView() {
    let eventView = EventView(sharedImage: sharedImage, dataSource: viewModel)
    eventView.eventImageView.hero.id = viewModel.event.id
    eventView.eventImageView.hero.modifiers = [.duration(0.4)]
    eventView.scrollView.hero.modifiers = [.translate(y: 100), .fade, .duration(0.4)]
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
    view = eventView
    self.eventView = eventView
		viewModel.userEvent()
			.then {[weak self] eventUser in
				guard let self = self else { return }
				let followState = FollowEventState.fromBool(
					eventUser.isFollow
				)
				self.viewModel.userFollowEventState = followState
				print("set initial value", followState)
				self.eventView?.followButtonView.setTitleColor(followState.iconColor, for: .normal)
				self.eventView?.followButtonView.setTitle(followState.iconName, for: .normal)
				self.eventView?.footerView.joinButtonState = eventUser.isJoin
					? .joined
					: .notJoined
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
