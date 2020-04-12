//
//  UserLocation.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

class UserLocation: NSObject, CLLocationManagerDelegate {
	private let locationManager = CLLocationManager()
	private let geocodeS = ReplaySubject<Geocode>.create(bufferSize: 1)
	
	var geocode$: Observable<Geocode> { geocodeS.asObserver() }
	
	private override init() {
		super.init()
		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		locationManager.delegate = self
		initUserLocation()
	}
	
	static let shared = UserLocation()
	
	private func initUserLocation() {
		let status = CLLocationManager.authorizationStatus()
		switch status {
		case .authorizedAlways, .authorizedWhenInUse:
			locationManager.startUpdatingLocation()
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		default: return
		}
	}

	func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    guard status == .authorizedAlways || status == .authorizedAlways else {
      return
    }
    manager.startUpdatingLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    manager.stopUpdatingLocation()
	
		GeolocationAPI.shared.reverseGeocode(byCoordinate: locations[0].coordinate)
			.then {[weak self] geocode in self?.geocodeS.onNext(geocode) }
			.catch { print($0.localizedDescription) }
  }
}
