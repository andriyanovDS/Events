//
//  CreatedEventsConfigurator.swift
//  Events
//
//  Created by Dmitry on 06.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class CreatedEventsConfigurator {
  func configure() -> CreatedEventsViewController {
    let repository = CreatedEventsFirestoreRepository()
    let viewModel = CreatedEventsViewModel(repository: repository)
    let viewController = CreatedEventsViewController.instantiate(with: viewModel)
    return viewController
  }
}
