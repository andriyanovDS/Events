//
//  RootScreenViewControllerLocationExtension.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import CoreLocation

extension RootScreenViewController: CLLocationManagerDelegate {

    func initializeUserLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.startUpdatingLocation()

//            onChangeUserLocation(coordinate: CLLocationCoordinate2D(latitude: 55.755786, longitude: 37.617633))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinates: CLLocation = locations[0]
        manager.stopUpdatingLocation()
        onChangeUserLocation(coordinate: coordinates.coordinate)
    }
}
