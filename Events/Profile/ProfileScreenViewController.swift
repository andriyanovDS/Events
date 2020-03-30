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
    viewModel.attemptToOpenUserDetails()
  }

	private func setupView() {
    profileScreenView = ProfileScreenView()
    view = profileScreenView
    setupButtons()
    profileScreenView.editButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
    profileScreenView.avatarViewButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
    profileScreenView.logoutButton.addTarget(self, action: #selector(onLogout), for: .touchUpInside)
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
  
  private func loadAvatarImage(_ avatarExternalUrl: String) {
    let url = URL(string: avatarExternalUrl, relativeTo: nil)
    guard let imageUrl = url else {
      return
    }
    DispatchQueue.global(qos: .background).async {
      let data = try? Data(contentsOf: imageUrl)
      guard let imageData = data else {
        return
      }
      DispatchQueue.main.async {
        self.profileScreenView.avatarImageView.image = UIImage(data: imageData)
      }
    }
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
  func onUserDidChange(user: User) {
    profileScreenView.userNameLabel.text = user.firstName
    if let avatarUrl = user.avatar {
      loadAvatarImage(avatarUrl)
    }
  }
}

extension ProfileScreenViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.x = 0
  }
}
