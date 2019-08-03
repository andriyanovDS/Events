//
//  Geocode.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

struct GeocodeResult: Decodable {
    let status: String
    let results: [Geocode]

    func mainGeocode() -> Geocode? {
        return results
            .sorted(by: { $0.address_components.count > $1.address_components.count })
            .first
    }
}
