//
//  ModalScreenViewModel.swift
//  Events
//
//  Created by Сослан Кулумбеков on 05/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class PermissionModalScreenViewModel {
    var coordinator: PermissionModalScreenViewCoordinator?
    func closeModal() {
        coordinator?.closeModal()
    }
}

protocol PermissionModalScreenViewCoordinator {
    func closeModal()
}
