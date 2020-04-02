//
//  ProfileScreenViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import RxSwift

class ProfileScreenViewController: UIViewController, ViewModelBased {
  var viewModel: ProfileScreenViewModel!
  var profileScreenView: ProfileScreenView!
	private var actions: [Action] = []
	private let disposeBag = DisposeBag()
	
	private struct Action {
		let iconName: String
		let title: String
		let action: () -> Void
	}
  
  override func viewDidLoad() {
    super.viewDidLoad()
		
		actions = [
			Action(
				iconName: "event",
				title: NSLocalizedString("Create event", comment: "Create an event"),
				action: viewModel.onCreateEvent
			),
			Action(
				iconName: "card.travel",
				title: NSLocalizedString("Created events", comment: "Profile screen: created events"),
				action: viewModel.openCreatedEvents
			),
			Action(
				iconName: "settings",
				title: NSLocalizedString("Settings", comment: "User settings"),
				action: viewModel.openUserDetails
			)
		]
    viewModel.delegate = self
		setupView()
    viewModel.onLoad()
  }

	private func setupView() {
    profileScreenView = ProfileScreenView()
    view = profileScreenView
    setupButtons()
		profileScreenView.editButton.rx.tap
			.subscribe(onNext: {[weak self] _ in self?.viewModel.openUserDetails() })
			.disposed(by: disposeBag)
		
		profileScreenView.avatarViewButton.rx.tap
		.subscribe(onNext: {[weak self] _ in self?.viewModel.openUserDetails() })
		.disposed(by: disposeBag)
		
    profileScreenView.logoutButton.rx.tap
		.subscribe(onNext: {[weak self] _ in self?.viewModel.logout() })
		.disposed(by: disposeBag)
  }
  
  @objc func onLogout() {
    viewModel.logout()
  }
  
  @objc func editProfile() {
    viewModel.openUserDetails()
  }
  
  @objc func createEvent() {
    viewModel.onCreateEvent()
  }
  
  @objc func openSettings() {
    
  }
  
  private func setupButtons() {
		let buttons = actions.map { v -> ProfileActionButton in
			let button = ProfileActionButton(
				labelText: v.title,
				subtitleText: nil,
				iconName: v.iconName
			)
			button.rx.tap
				.subscribe(onNext: { v.action() })
				.disposed(by: disposeBag)
			return button
		}
		profileScreenView.setupButtons(buttons)
  }
}

extension ProfileScreenViewController: ProfileScreenViewModelDelegate {
	func onUserDidChange(user: User, isAvatarImageChanged: Bool) {
    profileScreenView.userNameLabel.text = user.firstName
		if isAvatarImageChanged, let imageUrl = user.avatar {
			profileScreenView?.updateAvatar(imageUrl: imageUrl)
    }
  }
}
