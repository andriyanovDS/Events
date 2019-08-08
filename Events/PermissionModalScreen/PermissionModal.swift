//
//  Modal.swift
//  Events
//
//  Created by Сослан Кулумбеков on 09/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct PermissionModal {
    let title: String
    let imageUrl: String
    let description: String
    let buttonLabelText: String
}

enum PermissionModalType {
    case photo, geolocation, notifications
    
    func model() -> PermissionModal {
        switch self {
        case .photo:
            return PermissionModal(
                title: "Внимание",
                imageUrl: "",
                description: "Разрешите доступ к камере в настройках",
                buttonLabelText: "Понятно"
            )
        case .geolocation:
            return PermissionModal(
                title: "Внимание",
                imageUrl: "",
                description: "Разрешите доступ к геолокации",
                buttonLabelText: "Понятно"
            )
        case .notifications:
            return PermissionModal(
                title: "Внимание",
                imageUrl: "",
                description: "Разрешите доступ к геолокации",
                buttonLabelText: "Понятно"
            )
        }
    }
}

