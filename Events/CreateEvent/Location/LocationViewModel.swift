//
//  LocationViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 07/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import RxFlow
import RxCocoa

class LocationViewModel: Stepper {
  weak var delegate: LocationViewModelDelegate?
  let steps = PublishRelay<Step>()
  var geocode: Geocode?
  private let disposeBag = DisposeBag()

  init() {
		UserLocation.shared.geocode$
      .take(1)
      .subscribe(onNext: {[weak self] geocode in
        self?.geocode = geocode
        self?.delegate?.onLocationNameDidChange(geocode.fullLocationName())
      })
      .disposed(by: disposeBag)
  }

  func openLocationSearchBar() {
    steps.accept(EventStep.locationSearch(onResult: { geocode in
      self.geocode = geocode
      self.delegate?.onLocationNameDidChange(geocode.fullLocationName())
    }))
  }

  func openNextScreen() {
    guard let geocode = self.geocode else { return }
    delegate?.onResult(geocode)
  }
}

protocol LocationViewModelDelegate: class {
  var onResult: ((Geocode) -> Void)! { get }
  func onLocationNameDidChange(_: String)
}
