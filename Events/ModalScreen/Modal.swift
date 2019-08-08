//
//  Modal.swift
//  Events
//
//  Created by Сослан Кулумбеков on 09/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct Modal {
    let title: String
    let imageUrl: String
    let description: String
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
                description: "Разрешите доступ к камере в настройках",
                buttonLabelText: "Понятно"
            )
        }
    }
}
