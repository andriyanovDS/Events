//
//  Prediction.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct Prediction: Decodable, Equatable {
  let description: String
  let place_id: String

  static func == (lhs: Prediction, rhs: Prediction) -> Bool {
    return lhs.place_id == rhs.place_id
  }
}

struct PredictionsResponse: Decodable {
  let status: String
  let predictions: [Prediction]
}
