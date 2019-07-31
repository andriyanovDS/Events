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
        print(1)
    }
}

protocol PopUpWindowCoordinator: class {
    func dismissPopUp()
}
