//
//  PopUpWindowViewController.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

protocol PopUpDelegate {
    func hadleDismissal()
}


class PopUpWindowViewController: UIViewController {
    var coordinator: MainCoordinator?
    var delegate: PopUpDelegate?
    var viewModel: PopUpWindowViewModel?
    lazy var notificationLabel: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = UIFont(name: "CeraPro-Medium", size: 16)
        lable.textColor = UIColor.gray900()
        lable.textAlignment = .left
        return lable
    }()
    func setupView(with labelText: String) {
        notificationLabel.text = labelText
    }
    lazy var button: UIButtonScaleOnPress = {
        let button = UIButtonScaleOnPress()
        button.backgroundColor = .blue
        button.setTitle("Понятно", for: .normal)
        button.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    override func viewDidLoad() {
        setupNotification()
        setupButton()
    }
    @objc func closeModal(){
        coordinator?.openUserDetails()
    }
    func setupNotification(){
        self.view.backgroundColor = .white
        self.view.addSubview(notificationLabel)
        notificationLabel.numberOfLines = 2
        NSLayoutConstraint.activate([
            notificationLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -28),
            notificationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    func setupButton() {
        self.view.addSubview(button)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50),
            button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12)
            ])
    }
    
}
