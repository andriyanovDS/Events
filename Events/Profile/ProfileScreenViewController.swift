//
//  ProfileScreenViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 09/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class ProfileScreenViewController: UIViewController {

    var coordinator: ProfileScreenCoordinator?
    let viewModel = ProfileScreenViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator = ProfileScreenCoordinator(navigationController: navigationController!)
        viewModel.coordinator = coordinator
        viewModel.attemptToOpenUserDetails()
        setupView()
    }

    @objc func onLogout() {
        viewModel.logout()
    }

}

extension ProfileScreenViewController {

    func setupView() {
        view.backgroundColor = .white
        setupLogoutButton()
    }

    func setupLogoutButton() {
        let button = ButtonWithBorder()

        button.setTitle("Выйти", for: .normal)
        button.setTitleColor(UIColor.gray600(), for: .normal)
        button.layer.borderColor = UIColor.gray600().cgColor
        button.titleLabel?.font = UIFont(name: "CeraPro-Medium", size: 20)
        button.addTarget(self, action: #selector(onLogout), for: .touchUpInside)

        view.addSubview(button)
        setupLogoutButtonConstraints(button)
    }

    func setupLogoutButtonConstraints(_ button: UIView) {
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            button.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}
