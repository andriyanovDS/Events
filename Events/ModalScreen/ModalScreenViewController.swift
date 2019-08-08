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
    let permissionModal: Modal
    init(modalType: ModalType) {
        self.permissionModal = modalType.model()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadView()
        viewModel = ModalScreenViewModel()
        viewModel?.coordinator = coordinator
    }
    
    override func loadView() {
        modalScreenView = ModalScreenView(dataView: permissionModal)
        view = modalScreenView
        modalScreenView.submitButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
    }
    
    @objc func closeModal() {
        viewModel?.closeModal()
    }
}
