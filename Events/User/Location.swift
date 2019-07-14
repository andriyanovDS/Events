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
    let apiService = GeocodeAPI()
    let location = GetAddress(
        lng: coordinate.longitude,
        lat: coordinate.latitude
    )
    apiService.send(
        location,
        completion: {result in
            switch result {
            case .success(let geocodes):
                let mostUsefulGeocode = geocodes
                    .sorted(by: { $0.address_components.count > $1.address_components.count })
                    .first

                guard let geocode = mostUsefulGeocode else {
                    return
                }
                geocodeS.on(.next(geocode))
            case .failure:
                print("Failure", result)
            }
    })
}
