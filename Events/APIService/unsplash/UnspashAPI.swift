//
//  UnspashAPI.swift
//  Events
//
//  Created by Dmitry on 16.02.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Promises

let UNSPLASH_ACCESS_KEY = "WrFAWnX0M140jGm3WRlPcY1OkCa_MBkPKT8k-Cu_D3E"

func convertRawUrlToResizedUrl(url: String, width: CGFloat) -> String {
	var params: [String: CGFloat] = [:]
	params["dpi"] = UIScreen.main.scale
	params["w"] = width * UIScreen.main.scale
	return params.reduce(url, { (result, param) -> String in
		let (key, value) = param
		return result + "&\(key)=\(Int(value))"
	})
}

class UnsplashAPI: APIClientBase {

	init() {
		super.init(baseURL: "https://api.unsplash.com/")!
	}
	
	static let shared = UnsplashAPI()
	
	func searchImages(by query: String, count: Int) -> Promise<[UnsplashResultItem]> {
		var params: [String: String] = [:]
		params["client_id"] = UNSPLASH_ACCESS_KEY
		params["query"] = query
		params["page"] = "1"
		let endpoint = self.url(for: "search/photos", with: params)
		return Promise { resolve, reject in
			let task = self.session.dataTask(with: URLRequest(url: endpoint)) { data, _, error in
				if let requestError = error {
					reject(requestError)
					return
				}
				if let response = data {
					do {
						let searchPhotosResult = try JSONDecoder().decode(UnsplashResult.self, from: response)
						resolve(searchPhotosResult.results)
					} catch {
						reject(error)
					}
				}
			}
			task.resume()
		}
	}
}
