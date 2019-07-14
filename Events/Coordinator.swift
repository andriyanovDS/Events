//
//  Coordinator.swift
//  Events
//
//  Created by Дмитрий Андриянов on 10/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import RxSwift

protocol Coordinator {
    
    var navigationController: UINavigationController { get }
    
    func start()
}

protocol CoordinatedViewController {
    var coordinator: Coordinator? { get set }
}

class MainCoordinator: Coordinator {
    
    var userDisposable: Disposable?
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func openLoginScreen() {
        let viewController = LoginViewController()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func openRootScreen() {
        let controller = TabBarViewController()
        controller.coordinator = self
        controller.setupViewControllers()
        navigationController.pushViewController(controller, animated: false)
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
        userDisposable = userObserver
            .take(1)
            .subscribe(onNext: { user in
                self.userDisposable = nil
                if user == nil {
                    self.openLoginScreen()
                    return
                }
                self.openRootScreen()
            })
    }
    
    deinit {
        userDisposable?.dispose()
    }
}
