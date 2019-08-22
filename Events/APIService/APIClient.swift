//
//  APIClient.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

typealias ResultCallback<Value> = (Result<Value, Error>) -> Void

class APIClientBase {

  let baseURL: URL
  let session = URLSession(configuration: .default)

  init?(baseURL: String) {
    guard let url = URL(string: baseURL) else {
      return nil
    }
    self.baseURL = url
  }

  func endpoint(for path: String?, params: [String: String]) -> URL {

    let optionalUrl = path.foldL(
      none: { baseURL },
      some: { path in URL(string: path, relativeTo: baseURL) }
    )

    guard let url = optionalUrl else {
      fatalError("Wrong url")
    }
    
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    components.queryItems = params.map { v in
      return URLQueryItem(name: v.key, value: v.value)
    }
    return components.url!
  }
}
