//
//  PopUpWindowViewModel.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct Popup {
    let title: String
    let imageUrl: String?
    let description: String?
    let buttonLabelText: String
}

enum PopupType {
    case Commom
}

class PopupWindowViewModel {
    weak var coordinator: PopupWindowCoordinator?
    let popup: Popup
    func closeModal() {
        coordinator?.dismissPopup()
    }
    
    init(title: String, image: String?, description: String?, buttonText: String) {
        popup = Popup(title: title, imageUrl: image, description: description, buttonLabelText: buttonText)
    }
}

protocol PopupWindowCoordinator: class {
    func dismissPopup()
}
