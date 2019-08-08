//
//  RootScreenNavigationController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class RootScreenNavigationController: UINavigationController {

  var coordinator: RootScreenCoordinator?

  override func viewDidLoad() {
    super.viewDidLoad()

    coordinator = RootScreenCoordinator(navigationController: self)
    coordinator?.start()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hideNavigationBar()
  }

  func hideNavigationBar() {
    tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
  }
}
