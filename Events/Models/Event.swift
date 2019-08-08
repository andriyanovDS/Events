//
//  Event.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct Description {
  let title: String
  let imageUrl: String?
  let text: String
}

struct Event {
  let name: String
  let author: String
  let location: Location
  let durationInMinutes: Int
  let createDate: Date
  let categories: [Category]
  let description: [Description]
}
