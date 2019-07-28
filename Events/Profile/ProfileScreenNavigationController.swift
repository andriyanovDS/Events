//
//  ProfileScreenNavigationController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 22/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class ProfileScreenNavigationController: UIViewController {

    var coordinator: ProfileScreenCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator = ProfileScreenCoordinator(navigationController: self.navigationController!)
        coordinator?.start()
    }
}
