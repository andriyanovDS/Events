//
//  Location.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

private let geocodeS = ReplaySubject<Geocode>.create(bufferSize: 1)

let geocodeObserver = geocodeS.asObserver()

func onChangeUserLocation(coordinate: CLLocationCoordinate2D) {
  let apiService = GeolocationAPI()
  let location = GetAddressByCoordinate(
    lng: coordinate.longitude,
    lat: coordinate.latitude
  )
  apiService.reverseGeocodeByCoordinate(
    coordinate: location,
    completion: {result in
      switch result {
      case .success(let geocodes):
        guard let geocode = geocodes.mainGeocode() else {
          return
        }
        
        geocodeS.on(.next(geocode))
      case .failure:
        print("Failure", result)
      }
  })
}

func onChangeUserLocation(geocode: Geocode) {
  geocodeS.on(.next(geocode))
}
