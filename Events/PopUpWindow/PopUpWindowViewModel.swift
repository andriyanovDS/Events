//
//  PopUpWindowViewModel.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

class PopUpWindowViewModel {
    weak var coordinator: PopUpWindowCoordinator?

    func closeModal() {
        coordinator?.openUserDetails()
    }
}

protocol PopUpWindowCoordinator: class {
    func openUserDetails()
}
