//
//  SearchBarRouter.swift
//  Events
//
//  Created by Дмитрий Андриянов on 06/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class SearchBarRouter {
    
    func navigateToCalendar(navigationController: UINavigationController) {
        let calendarViewController = CalendarViewController()
        navigationController.pushViewController(calendarViewController, animated: true)
    }
}
