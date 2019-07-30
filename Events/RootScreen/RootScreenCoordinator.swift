//
//  RootScreenCoordinator.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class RootScreenCoordinator: Coordinator {
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

    func openLocationSearch() {
        let viewController = LocationSearchViewController()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .coverVertical
        navigationController.show(viewController, sender: self)
    }

    func start() {
        let rootScreenViewController = RootScreenViewController()
        rootScreenViewController.coordinator = self
        navigationController.pushViewController(rootScreenViewController, animated: true)
    }
}
