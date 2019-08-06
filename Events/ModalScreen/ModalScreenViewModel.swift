//
//  ModalScreenViewModel.swift
//  Events
//
//  Created by Сослан Кулумбеков on 05/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit
struct Modal {
    let title: String
    let imageUrl: String
    let desciption: String
    let buttonLabelText: String
}

enum ModalType {
    case permissionModal
    
    func model() -> Modal {
        switch self {
        case .permissionModal:
            return Modal(
                title: "Внимание",
                imageUrl: "📷",
                desciption: "Разрешите доступ к камере в настройках",
                buttonLabelText: "Понятно"
            )
        }
    }
}

class ModalScreenViewModel {
    var coordinator: ModalScreenViewCoordinator?
    let model: Modal
    func closeModal() {
        coordinator?.closeModal()
    }
    init(type: ModalType) {
        model = type.model()
    }
}

protocol ModalScreenViewCoordinator {
    func closeModal()
}
