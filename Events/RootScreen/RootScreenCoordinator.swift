//
//  RootScreenCoordinator.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class RootScreenCoordinator: Coordinator, LocationSearchCoordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func openCalendarScreen(selectedDates: SelectedDates, onComplete: @escaping (SelectedDates) -> Void) {
        let calendarViewController = CalendarViewController()
        calendarViewController.modalPresentationStyle = .overCurrentContext
        calendarViewController.isModalInPopover = true
        calendarViewController.onResult = onComplete
        calendarViewController.initialSelectedDateFrom = selectedDates.from
        calendarViewController.initialSelectedDateTo = selectedDates.to
        navigationController.present(calendarViewController, animated: false, completion: nil)
    }

    func openLocationSearch(onResult: @escaping (Geocode) -> Void) {
        let viewController = LocationSearchViewController()
        viewController.coordinator = self
        viewController.onClose = onResult
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .coverVertical
        navigationController.present(viewController, animated: true, completion: nil)
    }

    func onLocationDidSelected() {
        navigationController.dismiss(animated: false, completion: nil)
    }

    func start() {
        let rootScreenViewController = RootScreenViewController()
        rootScreenViewController.coordinator = self
        navigationController.pushViewController(rootScreenViewController, animated: true)
    }
}
