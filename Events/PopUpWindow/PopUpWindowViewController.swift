//
//  PopUpWindowViewController.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class PopupWindowViewController: UIViewController {
    var viewModel: PopupWindowViewModel?
    
    weak var coordinator: PopupWindowCoordinator? {
        didSet {
            viewModel?.coordinator = coordinator
        }
    }
    var popupScreenView: PopupScreenView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadView()
    }
    func setupView(titleLabel: String, image: String?, desciption: String?, buttonLabelText: String) {
        viewModel = PopupWindowViewModel(
            title: titleLabel,
            image: image ?? nil,
            description: desciption ?? nil,
            buttonText: buttonLabelText
        )
    }
    
    override func loadView() {
        popupScreenView = PopupScreenView()
        view = popupScreenView
        popupScreenView.okButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        popupScreenView.titleLabel.text = viewModel?.popup.title
        popupScreenView.okButton.setTitle(viewModel?.popup.buttonLabelText, for: .normal)
    }
    
    @objc func closePopup() {
        viewModel?.closeModal()
    }
}
