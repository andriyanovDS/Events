//
//  RootScreenConfigurator.swift
//  Events
//
//  Created by Dmitry on 01.05.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class RootScreenModuleConfigurator {
  func configure() -> RootScreenViewController {
    let db = RootScreenRepositoryFirestore()
    let viewModel = RootScreenViewModel(db: db)
    let viewController = RootScreenViewController.instantiate(with: viewModel)
    return viewController
  }
}
