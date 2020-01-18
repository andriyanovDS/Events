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
        title: NSLocalizedString("Need access",comment: "Permission: title"),
        image: "camera",
        description: NSLocalizedString(
          "Camera access",
          comment: "Permission: get camera access"
        ),
        buttonLabelText: NSLocalizedString(
          "OpenSettings",
          comment: "Permission: open settings to give access"
        )
      )
    case .library:
      return PermissionModal(
        title: NSLocalizedString("Need access",comment: "Permission: title"),
        image: "camera",
        description: NSLocalizedString(
          "Galery access",
          comment: "Permission: get gallery access"
        ),
        buttonLabelText: NSLocalizedString(
          "OpenSettings",
          comment: "Permission: open settings to give access"
        )
      )
    case .geolocation:
      return PermissionModal(
        title: NSLocalizedString("Need access",comment: "Permission: title"),
        image: "gallery",
        description: NSLocalizedString(
          "Geolocation access",
          comment: "Permission: get geolocation access"
        ),
        buttonLabelText: NSLocalizedString(
          "OpenSettings",
          comment: "Permission: open settings to give access"
        )
      )
    case .notifications:
      return PermissionModal(
        title: NSLocalizedString("Need access",comment: "Permission: title"),
        image: "location",
        description: NSLocalizedString(
          "Notification access",
          comment: "Permission: get notification access"
        ),
        buttonLabelText: NSLocalizedString(
          "OpenSettings",
          comment: "Permission: open settings to give access"
        )
      )
    }
  }
}
