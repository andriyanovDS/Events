//
//  ProfileScreenViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia

class ProfileScreenViewController: UIViewController, ProfileScreenViewModelDelegate {
  
  var coordinator: ProfileScreenCoordinator?
  let viewModel = ProfileScreenViewModel()
  
  var profileScreenView: ProfileScreenView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    coordinator = ProfileScreenCoordinator(navigationController: navigationController!)
    viewModel.coordinator = coordinator
    viewModel.delegate = self
    viewModel.attemptToOpenUserDetails()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.isNavigationBarHidden = true
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
  
  func onUserDidChange(user: User) {
    profileScreenView.userNameLabel.text = user.firstName
    if let avatarUrl = user.avatar {
      loadAvatarImage(avatarUrl)
    }
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
      labelText: "Создать событие",
      subtitleText: nil,
      iconName: "event"
    )
    createTaskButton.addTarget(self, action: #selector(createEvent), for: .touchUpInside)
    let settingsButton = ProfileActionButton(
      labelText: "Настройки",
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

extension ProfileScreenViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.x = 0
  }
}
