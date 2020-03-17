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

struct DescriptionWithImageUrls: Codable {
  let isMain: Bool
  let id: String
  let title: String?
  let imageUrls: [String]
  let text: String
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

struct Event: Codable {
  let name: String
  let author: String
  let location: Location
  let dates: [String]
	let isPublic: Bool
  let duration: EventDurationRange
  let createDate: String
  let categories: [CategoryId]
  let description: [DescriptionWithImageUrls]
	
	static func format(date: Date) -> String {
		let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fbDateFormat
    return dateFormatter.string(from: date)
	}
}
