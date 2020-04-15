//
//  Event.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import Photos

protocol Description: Equatable {
	var isMain: Bool { get }
	var id: String { get }
	var title: String? { get set }
	var text: String { get set }
}

extension Description {
	static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
}

struct DescriptionWithAssets: Description, Equatable {
  let isMain: Bool
  let id: String
  var title: String?
  var assets: [Asset]
  var text: String
  
  struct Asset: Hashable {
    let asset: PHAsset
    let localUrl: URL
  }
  
	init(
    isMain: Bool,
    title: String? = nil,
    assets: [Asset] = [],
    text: String = ""
  ) {
    self.isMain = isMain
    self.title = title
    self.assets = assets
    self.text = text
    id = UUID().uuidString
  }
}

struct DescriptionWithImageUrls: Description, Codable, Equatable {
  let isMain: Bool
  let id: String
  var title: String?
  var imageUrls: [String]
  var text: String
}

struct EventLocation: Codable {
  let lat: Double
  let lng: Double
  let fullName: String
}

struct Event: Codable {
  let id: String
  var name: String
  let author: String
  var isPublic: Bool
  var location: EventLocation
  var dates: [Date]
	let isRemoved: Bool
  var duration: EventDurationRange
  let createDate: Date
	var lastUpdateAt: Date?
  var categories: [CategoryId]
  var description: [DescriptionWithImageUrls]
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
}

extension Event: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		 return lhs.id == rhs.id
	 }
}

struct UserEvent: Codable {
	let eventId: String
	let userId: String
	var isFollow: Bool
	var isJoin: Bool
	let isAuthor: Bool
}
