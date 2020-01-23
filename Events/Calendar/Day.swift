//
//  Day.swift
//  Events
//
//  Created by Дмитрий Андриянов on 07/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct Day {
  let dayOfMonth: Int
  let dayOfWeek: Int
  let isToday: Bool
  let isInPast: Bool
  let date: Date
  let isLastInMonth: Bool
}

func dateToKey(_ date: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyyMMdd"
  return formatter.string(from: date)
}
