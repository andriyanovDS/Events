//
//  LoginCoordinator.swift
//  Events
//
//  Created by Дмитрий Андриянов on 23/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class LoginCoordinator: Coordinator {
  weak var delegate: LoginCoordinatorDelegate?
  var navigationController: UINavigationController
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func openRootScreen() {
    delegate?.openRootScreen()
  }
  
  func start() {
    let loginScreenViewController = LoginViewController()
    loginScreenViewController.coordinator = self
    navigationController.pushViewController(loginScreenViewController, animated: false)
  }
}

protocol LoginCoordinatorDelegate: class {
  func openRootScreen()
}
