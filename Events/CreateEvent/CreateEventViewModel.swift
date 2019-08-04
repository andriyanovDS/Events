//
//  CreateEventViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift

class CreateEventViewModel {
    let delegate: CreateEventViewModelDelegate
    weak var coordinator: CreateEventCoordinator?
    private let disposeBag = DisposeBag()

    init(delegate: CreateEventViewModelDelegate) {
        self.delegate = delegate
        geocodeObserver
            .take(1)
            .subscribe(onNext: { geocode in
                self.delegate.onReceiveCurrentLocationName(geocode.fullLocationName())
            })
            .disposed(by: disposeBag)
    }

    func closeScreen() {
        delegate.navigationController?.popViewController(animated: true)
    }

    func openLocationSearchBar() {
        coordinator?.openLocationSearchBar(onResult: { geocode in
            self.delegate.onChangeLocationName(geocode.fullLocationName())
        })
    }
}

protocol CreateEventViewModelDelegate: UIViewControllerWithActivityIndicator {
    func onChangeLocationName(_: String)
    func onReceiveCurrentLocationName(_: String)
}

protocol CreateEventCoordinator: class {
    func openLocationSearchBar(onResult: @escaping (Geocode) -> Void)
}
