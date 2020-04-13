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

protocol UserLocationManagerDelegate: class {
	func userLocationManager(_: UserLocationManager, didUpdateGeocode: Geocode)
	func userLocationManager(_: UserLocationManager, didFailWithError: Error)
}

extension UserLocationManagerDelegate {
	func userLocationManager(_: UserLocationManager, didFailWithError error: Error) {
		print(error.localizedDescription)
	}
}

protocol UserLocationManager: CLLocationManagerDelegate {
	var geocode: Geocode? { get set }
	var delegate: UserLocationManagerDelegate? { get }
	func requestLocation()
}

@dynamicMemberLookup
class UserLocationManagerImpl: NSObject, UserLocationManager {
	weak var delegate: UserLocationManagerDelegate? {
		didSet { setupLocationManager() }
	}
	var geocode: Geocode?
	fileprivate let locationManager = CLLocationManager()
	
	override init() {
		super.init()
		
		locationManager.delegate = self
		locationManager.distanceFilter = 200
		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
	}
	
	subscript<T>(dynamicMember member: ReferenceWritableKeyPath<CLLocationManager, T>) -> T {
		get { return locationManager[keyPath: member] }
		set { locationManager[keyPath: member] = newValue }
	}
	
	func requestLocation() {
		assertionFailure("Must be overridden in subclass")
	}
	
	private func setupLocationManager() {
		let status = CLLocationManager.authorizationStatus()
		switch status {
		case .authorizedAlways, .authorizedWhenInUse:
			requestLocation()
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
    requestLocation()
  }
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		GeolocationAPI.shared.reverseGeocode(byCoordinate: locations[0].coordinate)
			.then {[weak self] geocode in
				guard let self = self else { return }
				self.geocode = geocode
				self.delegate?.userLocationManager(self, didUpdateGeocode: geocode)
			}
			.catch { print($0.localizedDescription) }
  }
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		self.delegate?.userLocationManager(self, didFailWithError: error)
	}
}

class UserLocationManagerRequestOnce: UserLocationManagerImpl {
	override func requestLocation() {
		locationManager.requestLocation()
	}
}

class UserLocationManagerUpdating: UserLocationManagerImpl {
	override func requestLocation() {
		locationManager.startUpdatingLocation()
	}
}
