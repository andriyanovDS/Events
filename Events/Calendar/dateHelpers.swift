//
//  dateHelpers.swift
//  Events
//
//  Created by Дмитрий Андриянов on 21/01/2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation

private func isSelectedDateFromFn(selectedDateFrom: Date?) -> (Date) -> Bool {
  return { date in
    selectedDateFrom
      .map { Calendar.current.isDate($0, equalTo: date, toGranularity: .day) }
      .getOrElse(result: false)
  }
 }

 private func isSelectedDateToFn(selectedDateTo: Date?) -> (Date) -> Bool {
  return { date in
    selectedDateTo
      .map { Calendar.current.isDate($0, equalTo: date, toGranularity: .day) }
      .getOrElse(result: false)
  }
 }

private func isDateBetween(_ dateFrom: Date) -> (Date) -> (Date) -> Bool {
  return { dateTo in { $0.isBetween(dateFrom, and: dateTo) } }
}

private func isDateInSelectedRangeFn(selectedDates: SelectedDates) -> (Date) -> Bool {
  let isBetween = selectedDates.to
    .ap(selectedDates.from.map { isDateBetween($0) })
    .getOrElse(result: { _ in false })
  return { isBetween($0) }
}

func dateToButtonHighlightStateFn(selectedDates: SelectedDates) -> (Date) -> ButtonHiglightState {
  let isSelectedDateFrom = isSelectedDateFromFn(selectedDateFrom: selectedDates.from)
  let isSelectedDateTo = isSelectedDateToFn(selectedDateTo: selectedDates.to)
  let isDateInSelectedRange = isDateInSelectedRangeFn(selectedDates: selectedDates)
  return { date in
    if selectedDates.from != nil && selectedDates.to == nil {
      return isSelectedDateFrom(date)
        ? ButtonHiglightState.single
        : ButtonHiglightState.notSelected
    }
    if isDateInSelectedRange(date) {
      return isSelectedDateFrom(date)
        ? ButtonHiglightState.from
        : isSelectedDateTo(date)
          ? ButtonHiglightState.to
          : ButtonHiglightState.inRange
    }
    return .notSelected
  }
}

private func datesToTitleFn(dateFormatter: DateFormatter) -> (Date) -> (Date) -> String {
  return { to in {
    dateFormatter.string(from: $0) + " - " + dateFormatter.string(from: to)
  }}
}

func selectedDatesToTitle(_ dates: SelectedDates) -> String? {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "dd MMM"
  dateFormatter.locale = Locale(identifier: "ru_RU")

  let titleFnOption = dates.to
    .map { datesToTitleFn(dateFormatter: dateFormatter)($0) }
    .orElse { date in dateFormatter.string(from: date) }

  return dates.from.ap(titleFnOption)
}

private func splitDaysByWeeks(days: [Day]) -> [[Day?]] {
  let weeks: [[Day]] = days.reduce([], { (acc, day) in
    var accumulated = acc
    if day.dayOfWeek == 1 {
      accumulated.append([day])
      return accumulated
    }
    let last = accumulated.reversed().last
    if last != nil {
      accumulated[accumulated.count - 1].append(day)
      return accumulated
    }
    return [[day]]
  })
  return weeks
    .enumerated()
    .map({ (weekOffset, week) -> [Day?] in
      let daysInWeek = 7
      let daysDifference = daysInWeek - week.count
      let finalWeek = Array.init(repeating: 0, count: daysInWeek)
        .enumerated()
        .map({ (offset, _) -> Day? in
          if weekOffset == 0 {
            let index = offset - daysDifference
            if index < 0 {
              return nil
            }
            return week[index]
          }
          if offset < week.count {
            return week[offset]
          }
          return nil
        })
      return finalWeek
    })
}

func generateMonths(monthsToDisplay: Int) -> [Month] {
  let dateFormatter = DateFormatter()
  dateFormatter.locale = Locale(identifier: "ru_RU")
  let startOfCurrentMonth = Date().startOfMonth()
  dateFormatter.dateFormat = "LLLL"
  let now = Date()
  let offsetTimeInterval = TimeInterval(
    TimeZone.current.secondsFromGMT(for: now)
  )
  return Array
    .init(repeating: 0, count: monthsToDisplay)
    .enumerated()
    .map({ (offset, _) -> Month in
      var dateComponents = DateComponents()
      dateComponents.month = offset
      let month = Calendar.current.date(byAdding: dateComponents, to: startOfCurrentMonth)!
      let daysRange = Calendar.current.range(of: .day, in: .month, for: month)!
      let startOfMonth = month.startOfMonth()
      let days = daysRange
        .map({ dayOfMonth -> Day in
        dateComponents.day = dayOfMonth - 1
        dateComponents.month = 0
        let day = Calendar
          .current
          .date(byAdding: dateComponents, to: startOfMonth)!
          .addingTimeInterval(offsetTimeInterval)
        let isToday = Calendar.current.isDateInToday(day)
        return Day(
          dayOfMonth: dayOfMonth,
          dayOfWeek: day.dayNumberOfWeek()!,
          isToday: isToday,
          isInPast: !isToday && day < now,
          date: day,
          isLastInMonth: dayOfMonth == daysRange.count
        )
      })
      let title = dateFormatter.string(from: month)
      let weeks = splitDaysByWeeks(days: days)
      return Month(title: title, days: weeks)
    })
}
