//
//  Event.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Photos

struct Description {
  let isMain: Bool
  let title: String?
  let assets: [PHAsset]
  let text: String
}

struct MutableDescription {
  let isMain: Bool
  var title: String?
  var assets: [PHAsset]
  var text: String

  func immutable() -> Description {
    Description(isMain: isMain, title: title, assets: assets, text: text)
  }
}

struct Event {
  let name: String
  let author: String
  let location: Location
  let dates: [Date]
  let duration: EventDurationRange
  let createDate: Date
  let categories: [Category]
  let description: [Description]
}
