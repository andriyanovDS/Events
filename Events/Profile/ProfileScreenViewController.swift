//
//  ProfileScreenViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ProfileScreenViewController: UIViewController, ViewModelBased {
  var viewModel: ProfileScreenViewModel!
  var profileScreenView: ProfileScreenView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.delegate = self
    viewModel.attemptToOpenUserDetails()
  }

  override func loadView() {
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
    let createTaskButton = ProfileActionButton(
      labelText: NSLocalizedString("Create event", comment: "create an event"),
      subtitleText: nil,
      iconName: "event"
    )
    createTaskButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
    let settingsButton = ProfileActionButton(
      labelText: NSLocalizedString("Settings", comment: "User settings"),
      subtitleText: nil,
      iconName: "settings"
    )
    settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
    profileScreenView.setupButtons([
      createTaskButton,
      settingsButton
      ])
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
