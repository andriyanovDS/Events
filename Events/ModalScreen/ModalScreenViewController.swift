//
//  ModalScreenViewController.swift
//  Events
//
//  Created by Сослан Кулумбеков on 05/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class ModalScreenViewController: UIViewController {
    var viewModel: ModalScreenViewModel?
    var modalScreenView: ModalScreenView!
    var coordinator: ModalScreenViewCoordinator?
    
    init(modalType: ModalType) {
        super.init(nibName: nil, bundle: nil)
        viewModel = ModalScreenViewModel(type: .permissionModal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadView()
        viewModel?.coordinator = coordinator
    }
    
    override func loadView() {
        modalScreenView = ModalScreenView()
        view = modalScreenView
        modalScreenView.submitButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        modalScreenView.titleLabel.text = viewModel?.model.title
        modalScreenView.descriptionLabel.text = viewModel?.model.desciption
        modalScreenView.image.text = viewModel?.model.imageUrl
        modalScreenView.submitButton.setTitle(viewModel?.model.buttonLabelText, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closePopup() {
        viewModel?.closeModal()
    }
}
