//
//  ModalScreenViewModel.swift
//  Events
//
//  Created by Сослан Кулумбеков on 05/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class PermissionModalScreenViewModel {
    var coordinator: PermissionModalScreenViewCoordinator?
    let url = URL(string: UIApplication.openSettingsURLString)
    
    func openAppSettings() {
        UIApplication.shared.open(url!, completionHandler: { (success) in
            print("Settings opened: \(success)")
        })
    }
    
    func closeModal() {
        coordinator?.closeModal()
    }
}

protocol PermissionModalScreenViewCoordinator {
    func closeModal()
}
