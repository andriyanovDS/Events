//
//  LocationViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 07/03/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import RxCocoa
import CoreLocation

class LocationViewModel: Stepper, ResultProvider {
  let onResult: ResultHandler<Geocode>
	weak var delegate: LocationViewModelDelegate?
  let steps = PublishRelay<Step>()
  var geocode: Geocode?
	let locationManager = UserLocationManagerRequestOnce()
	
  init(onResult: @escaping ResultHandler<Geocode>) {
    self.onResult = onResult
		locationManager.delegate = self
	}

  func openLocationSearchBar() {
    steps.accept(EventStep.locationSearch(onResult: { geocode in
      self.geocode = geocode
      self.delegate?.onLocationNameDidChange(geocode.fullLocationName())
    }))
  }

  func openNextScreen() {
    guard let geocode = self.geocode else { return }
		onResult(geocode)
  }
}

extension LocationViewModel: UserLocationManagerDelegate {
	func userLocationManager(_: UserLocationManager, didUpdateGeocode geocode: Geocode) {
		self.geocode = geocode
		delegate?.onLocationNameDidChange(geocode.fullLocationName())
	}
}

protocol LocationViewModelDelegate: class {
  func onLocationNameDidChange(_: String)
}
