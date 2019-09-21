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
  case camera, library, geolocation, notifications
  
  func model() -> PermissionModal {
    switch self {
    case .camera:
      return PermissionModal(
        title: "Нужен доступ",
        image: "camera",
        description: "Разрешите доступ к камере, чтобы сделать фотографию",
        buttonLabelText: "Разрешить доступ"
      )
    case .library:
      return PermissionModal(
        title: "Нет доступа",
        image: "camera",
        description: "Разрешите доступ к галерее, чтобы выбрать изображения и видео",
        buttonLabelText: "Разрешить"
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
