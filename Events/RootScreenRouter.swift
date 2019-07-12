//
//  RootScreenRouter.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class RootScreenRouter {
    
    func navigateToCalendar(
        navigationController: UINavigationController,
        selectedDates: SelectedDates,
        onComplete: @escaping (SelectedDates) -> Void
    ) {
        let calendarViewController = CalendarViewController()
        calendarViewController.modalPresentationStyle = .overCurrentContext
        calendarViewController.isModalInPopover = true
        calendarViewController.onResult = onComplete
        calendarViewController.initialSelectedDateFrom = selectedDates.from
        calendarViewController.initialSelectedDateTo = selectedDates.to
        navigationController.present(calendarViewController, animated: false, completion: nil)
    }
}
