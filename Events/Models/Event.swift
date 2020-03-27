//
//  Event.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Photos

struct DescriptionAsset {
	let asset: PHAsset
	let localUrl: URL
}

struct DescriptionWithAssets {
  let isMain: Bool
  let id: String
  let title: String?
  let assets: [DescriptionAsset]
  let text: String
}

struct DescriptionWithImageUrls: Codable, Equatable {
  let isMain: Bool
  let id: String
  let title: String?
  let imageUrls: [String]
  let text: String

  static func == (lhs: DescriptionWithImageUrls, rhs: DescriptionWithImageUrls) -> Bool {
    return lhs.id == rhs.id
  }
}

struct EventUser: Codable {
	let eventId: String
	let userId: String
	let isFollow: Bool
	let isJoin: Bool
}

class MutableDescription {
  let isMain: Bool
  let id: String
  var title: String?
  var assets: [DescriptionAsset]
  var text: String

  init(
    isMain: Bool,
    title: String? = nil,
    assets: [DescriptionAsset] = [],
    text: String = ""
  ) {
    self.isMain = isMain
    self.title = title
    self.assets = assets
    self.text = text
    id = UUID().uuidString
  }

  func immutable() -> DescriptionWithAssets {
    DescriptionWithAssets(isMain: isMain, id: id, title: title, assets: assets, text: text)
  }
}

extension MutableDescription: Equatable {
  static func == (lhs: MutableDescription, rhs: MutableDescription) -> Bool {
    return lhs.id == rhs.id
  }
}

struct EventLocation: Codable {
  let lat: Double
  let lng: Double
  let fullName: String
}

struct Event: Codable, Equatable {
  let id: String
  let name: String
  let author: String
  let isPublic: Bool
  let location: EventLocation
  let dates: [Date]
  let duration: EventDurationRange
  let createDate: Date
  let categories: [CategoryId]
  let description: [DescriptionWithImageUrls]
  var mainImageUrl: String? {
    description
      .first(where: { !$0.imageUrls.isEmpty })
      .chain { $0.imageUrls.first }
  }
  var dateLabelText: String {
    guard let firstDate = dates.first else {
      return ""
    }
    let lastDateOption = dates.last
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let startTime = dateFormatter.string(from: firstDate)
    let currentYear = Calendar.current.component(.year, from: Date())
    let labelWithOptionYear = {(date: Date) -> String in
      let dateYear = Calendar.current.component(.year, from: date)
      if dateYear == currentYear {
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter.string(from: date)
      }
      dateFormatter.dateFormat = "dd.MM YYYY"
      return dateFormatter.string(from: date)
    }
    if dates.count > 1, let lastDate = lastDateOption {
      return [firstDate, lastDate]
        .map { labelWithOptionYear($0) }
        .joined(separator: " - ") + " \(startTime)"
    }
    return "\(labelWithOptionYear(firstDate)) \(startTime)"
  }

  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
}
