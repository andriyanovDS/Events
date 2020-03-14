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
  let id: String
  let title: String?
  let assets: [PHAsset]
  let text: String
}

struct MutableDescription {
  let isMain: Bool
  let id: String
  var title: String?
  var assets: [PHAsset]
  var text: String

  init(
    isMain: Bool,
    title: String? = nil,
    assets: [PHAsset] = [],
    text: String = ""
  ) {
    self.isMain = isMain
    self.title = title
    self.assets = assets
    self.text = text
    id = UUID().uuidString
  }

  func immutable() -> Description {
    Description(isMain: isMain, id: id, title: title, assets: assets, text: text)
  }
}

extension MutableDescription: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
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
