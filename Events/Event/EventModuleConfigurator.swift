//
//  EventModuleConfigurator.swift
//  Events
//
//  Created by Dmitry on 01.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit.UIImage

class EventModuleConfigurator {
  func configure(
    with event: Event,
    sharedImage: UIImage? = nil,
    isInsideContextMenu: Bool = false
  ) -> EventViewController {
    let db = EventRepositoryFirestore()
    let viewModel = EventViewModel(event: event, db: db)
    let viewController = EventViewController(
      viewModel: viewModel,
      sharedImage: sharedImage,
      isInsideContextMenu: isInsideContextMenu
    )
    viewModel.delegate = viewController
    return viewController
  }
}
