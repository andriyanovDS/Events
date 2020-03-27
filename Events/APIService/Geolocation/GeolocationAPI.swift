//
//  GeolocationAPI.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

let GOOGLE_API_KEY = "AIzaSyDGC02immazUPTbJ89Ug5uBjHIONn0GJME"

struct GetAddressByCoordinate: APIRequest {
  typealias Response = GeocodeResult
  let lng: Double
  let lat: Double
}

struct GetAddressByPlaceId: APIRequest {
  typealias Response = GeocodeResult
  let placeId: String
}

struct GetPredictions: APIRequest {
  typealias Response = GeocodeResult
  let input: String
}

enum GeocoderError: Error {
  case badRequest(String)
}

class GeolocationAPI: APIClientBase {

  static let shared = GeolocationAPI()
  
  private init() {
    super.init(baseURL: "https://maps.googleapis.com/maps/api/")!
  }
  
  func reverseGeocodeByCoordinate(
    coordinate: GetAddressByCoordinate,
    completion: @escaping (Result<GetAddressByCoordinate.Response, GeocoderError>) -> Void
    ) {
    let params: [String: String] = [
      "latlng": "\(coordinate.lat),\(coordinate.lng)"
    ]
    reverseGeocode(params: params, completion: completion)
  }
  
  func reverseGeocodeByPlaceId(
    params: GetAddressByPlaceId,
    completion: @escaping (Result<GetAddressByCoordinate.Response, GeocoderError>) -> Void
    ) {
    reverseGeocode(params: ["place_id": params.placeId], completion: completion)
  }
  
  func predictions(
    input: String,
    completion: @escaping (Result<PredictionsResponse, GeocoderError>) -> Void
    ) {
    let params = [
      "key": GOOGLE_API_KEY,
      "input": input
    ]
    let endpoint = self.endpoint(for: "place/autocomplete/json", params: params)
    let task = session.dataTask(with: request(for: endpoint)) { data, _, error in
      if let requestError = error {
        completion(.failure(.badRequest(requestError.localizedDescription)))
        return
      }
      if let geoData = data {
        do {
          let geocoder = try JSONDecoder().decode(PredictionsResponse.self, from: geoData)
          completion(.success(geocoder))
        } catch {
          completion(.failure(.badRequest(error.localizedDescription)))
        }
      }
    }
    task.resume()
  }
  
  private func reverseGeocode(
    params: [String: String],
    completion: @escaping (Result<GeocodeResult, GeocoderError>) -> Void
    ) {
    var requestParams = params
    requestParams["key"] = GOOGLE_API_KEY
    requestParams["language"] = "en"
    let endpoint = self.endpoint(for: "geocode/json", params: requestParams)
    let task = session.dataTask(with: request(for: endpoint)) { data, _, error in
      if let requestError = error {
        completion(.failure(.badRequest(requestError.localizedDescription)))
        return
      }
      if let geoData = data {
        do {
          let geocoder = try JSONDecoder().decode(GeocodeResult.self, from: geoData)
          completion(.success(geocoder))
        } catch {
          completion(.failure(.badRequest(error.localizedDescription)))
        }
      }
    }
    task.resume()
  }
	
	private func request(for url: URL) -> URLRequest {
		var request = URLRequest(url: url)
		if let identifier = Bundle.main.bundleIdentifier {
			request.addValue(identifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
		}
		return request
	}
}
