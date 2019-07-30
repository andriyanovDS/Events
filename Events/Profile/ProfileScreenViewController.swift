//
//  ProfileScreenViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ProfileScreenViewController: UIViewController, ProfileScreenViewModelDelegate {

    var coordinator: ProfileScreenCoordinator?
    let viewModel = ProfileScreenViewModel()

    let contentView = UIView()
    let userInfoView = UIView()
    let userNameLabel = UILabel()
    var avatarViewButton = UIButton()
    var avatarImageView = UIImageView()

    var profileScreenView: ProfileScreenView!

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator = ProfileScreenCoordinator(navigationController: navigationController!)
        viewModel.coordinator = coordinator
        viewModel.delegate = self
        viewModel.attemptToOpenUserDetails()
        loadView()
    }

    override func loadView() {
        profileScreenView = ProfileScreenView()
        view = profileScreenView
        profileScreenView.editButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        profileScreenView.avatarViewButton.addTarget(self, action: #selector(editProfile), for: .touchUpInside)
        profileScreenView.logoutButton.addTarget(self, action: #selector(onLogout), for: .touchUpInside)
    }

    @objc func onLogout() {
        viewModel.logout()
    }

    @objc func editProfile() {
        
    }

    func onUserDidChange(user: User) {
        userNameLabel.text = user.firstName
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
                self.avatarImageView.image = UIImage(data: imageData)
            }
        }
    }
}

extension ProfileScreenViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}
