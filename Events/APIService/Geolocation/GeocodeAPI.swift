//
//  GeolocationAPI.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

let GOOGLE_API_KEY = "AIzaSyDGC02immazUPTbJ89Ug5uBjHIONn0GJME"

struct GetAddress: APIRequest {
    typealias Response = [Geocode]
    let lng: Double
    let lat: Double
}

enum GeocoderError: Error {
    case badRequest(String)
}

class GeocodeAPI: APIClientBase {

    init() {
        super.init(baseURL: "https://maps.googleapis.com/maps/api/geocode/json")!
    }

    func send(
        _ request: GetAddress,
        completion: @escaping (Result<GetAddress.Response, GeocoderError>) -> Void
    ) {
        let params: [String: String] = [
            "key": GOOGLE_API_KEY,
            "language": "en",
            "latlng": "\(request.lat),\(request.lng)"
        ]
        let endpoint = self.endpoint(for: nil, params: params)
        let task = session.dataTask(with: URLRequest(url: endpoint)) { data, response, error in
            if let requestError = error {
                completion(.failure(.badRequest(requestError.localizedDescription)))
                return
            }
            if let geoData = data {
                do {
                    let geocoder = try JSONDecoder().decode(GeocodeResult.self, from: geoData)
                    completion(.success(geocoder.results))
                } catch {
                    completion(.failure(.badRequest(error.localizedDescription)))
                }
            }
        }
        task.resume()
    }
}
