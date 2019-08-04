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

class MainCoordinator: Coordinator, LoginCoordinatorDelegate {

    var userDisposable: Disposable?
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func openLoginScreen() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.delegate = self
        loginCoordinator.start()
    }
    
    func openRootScreen() {
        let controller = TabBarViewController()
        controller.coordinator = self
        controller.setupViewControllers()
        navigationController.pushViewController(controller, animated: false)
    }
    
    func start() {
        navigationController.isNavigationBarHidden = true
        navigationController.view.backgroundColor = .white
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
