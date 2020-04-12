//
//  GeolocationAPI.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Promises
import CoreLocation

class GeolocationAPI: APIClientBase {
	
	private init() {
		 super.init(baseURL: "https://maps.googleapis.com/maps/api/")!
	 }

  static let shared = GeolocationAPI()
  
	func reverseGeocode(byCoordinate coordinate: CLLocationCoordinate2D) -> Promise<Geocode> {
    return reverseGeocode(with: [
			"latlng": "\(coordinate.latitude),\(coordinate.longitude)"
		])
  }
  
  func reverseGeocode(byPlaceId placeId: String) -> Promise<Geocode> {
		reverseGeocode(with: ["place_id": placeId])
  }
  
  func predictions(
    input: String,
    completion: @escaping (Result<[Prediction], Error>) -> Void
    ) -> () -> Void {
    let params = [
      "key": Environment.googleApiKey,
      "input": input
    ]
		let endpoint = self.url(for: "place/autocomplete/json", with: params)
    let task = session.dataTask(with: request(url: endpoint)) { data, _, error in
      if let requestError = error {
        completion(.failure(requestError))
        return
      }
			if let geoData = data {
        do {
          let response = try JSONDecoder().decode(PredictionsResponse.self, from: geoData)
					completion(.success(response.predictions))
        } catch let error {
          completion(.failure(error))
        }
      }
    }
    task.resume()
		return { task.cancel() }
  }
  
  private func reverseGeocode(with params: [String: String]) -> Promise<Geocode> {
    var requestParams = params
		requestParams["key"] = Environment.googleApiKey
    requestParams["language"] = Locale.current.languageCode
    let url = self.url(for: "geocode/json", with: requestParams)
		let request = self.request(url: url)
		return Promise { resolve, reject in
			let task = URLSession.shared.dataTask(with: request) { data, _, error in
				if let requestError = error {
					reject(requestError)
					return
				}
				if let geoData = data {
					do {
						let result = try JSONDecoder().decode(GeocodeResult.self, from: geoData)
						guard let geocode = result.mainGeocode() else {
							reject(GeocodeError.emptyGeocodes)
							return
						}
						resolve(geocode)
					} catch let error {
						reject(error)
					}
				}
			}
			task.resume()
		}
  }
	
	private func request(url: URL) -> URLRequest {
		var request = URLRequest(url: url)
		if let identifier = Bundle.main.bundleIdentifier {
			request.addValue(identifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
		}
		return request
	}
}

extension GeolocationAPI {
	
	enum GeocodeError: Error {
		case emptyGeocodes
	}
	
	struct GeocodeResult: Decodable {
		let status: String
		let results: [Geocode]

		func mainGeocode() -> Geocode? {
			return results
				.sorted(by: { $0.address_components.count > $1.address_components.count })
				.first
		}
	}
}
