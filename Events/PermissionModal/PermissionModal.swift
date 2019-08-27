//
//  PermissionModal.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct PermissionModal {
  let title: String
  let image: String
  let description: String
  let buttonLabelText: String
}

enum PermissionModalType {
  case photo, geolocation, notifications
  
  func model() -> PermissionModal {
    switch self {
    case .photo:
      return PermissionModal(
        title: "Нужен доступ",
        image: "camera",
        description: "Разрешите доступ к камере, чтобы сделать фотографию",
        buttonLabelText: "Разрешить доступ"
      )
    case .geolocation:
      return PermissionModal(
        title: "Внимание",
        image: "gallery",
        description: "Разрешите доступ к геолокации",
        buttonLabelText: "Понятно"
      )
    case .notifications:
      return PermissionModal(
        title: "Внимание",
        image: "location",
        description: "Разрешите доступ к геолокации",
        buttonLabelText: "Понятно"
      )
    }
  }
}
