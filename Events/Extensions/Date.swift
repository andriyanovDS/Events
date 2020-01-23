//
//  Date.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation

extension Date {

  func dayNumberOfWeek() -> Int? {
    return Calendar.current.dateComponents([.weekday], from: self).weekday
  }

  func startOfMonth() -> Date {
    return Calendar.current.date(
      from: Calendar.current.dateComponents(
        [.year, .month],
        from: Calendar.current.startOfDay(for: self))
      )!
  }

  func isBetween(_ date1: Date, and date2: Date) -> Bool {
    return (min(date1, date2) ... max(date1, date2)) ~= self
  }
}
