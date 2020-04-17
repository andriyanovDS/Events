//
//  CalendarDataSource.swift
//  Events
//
//  Created by Dmitry on 16.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class CalendarDataSource: NSObject {
  private var isFromDateInPast: Bool = false
  private(set) var selectedDateFrom: Date? {
    didSet { isFromDateInPast = false }
  }
  private(set) var selectedDateTo: Date?
  private let today = Date()
  private(set) var months: [Month] = []
  var activeMonthIndex: Int {
    guard let dateFrom = selectedDateFrom else {
      return months.firstIndex(where: {  $0.distanceFromCurrentMonth == 0 })!
    }
    let diff = differenceInMonths(from: today, to: dateFrom)
    return months.firstIndex(where: {  $0.distanceFromCurrentMonth == diff })!
  }
  
  var selectedDates: SelectedDates {
    SelectedDates(from: selectedDateFrom, to: selectedDateTo)
  }
  
  init(selectedDates: SelectedDates, minMonthsToDisplay: Int = 5) {
    selectedDateFrom = selectedDates.from
    selectedDateTo = selectedDates.to
    super.init()
    
    if let dateFrom = selectedDates.from {
      let diff = differenceInMonths(from: today, to: dateFrom)
      isFromDateInPast = diff < 0
    }
    months = generateMonths(minMonthsToDisplay: minMonthsToDisplay)
  }
  
  func selectDate(_ date: Date) {
    guard let from = selectedDateFrom else {
      selectedDateFrom = date
      return
    }
    if from == date && selectedDateTo == nil { return }
    if isFromDateInPast {
      selectedDateFrom = date
      return
    }
    guard selectedDateTo != nil  else {
      if from > date {
        selectedDateFrom = date
      } else { selectedDateTo = date }
      return
    }
    selectedDateFrom = date
    selectedDateTo = nil
  }
  
  func clearDates() {
    selectedDateTo = nil
    selectedDateFrom = nil
  }
  
  private func differenceInMonths(from: Date, to: Date) -> Int {
    let fromComponents = Calendar.current.dateComponents([.month, .year], from: from)
    let toComponents = Calendar.current.dateComponents([.month, .year], from: to)
    if fromComponents.year! == toComponents.year {
      return toComponents.month! - fromComponents.month!
    }
    let yearDiff = fromComponents.year! - toComponents.year!
    return -(fromComponents.month! - toComponents.month! + yearDiff * 12)
  }
  
  private func splitDaysByWeeks(_ days: [Day]) -> [[Day?]] {
    func addEmptyDays(to week: inout [Day?], action: (inout [Day?], [Day?]) -> Void) {
      let weekDaysCount = week.count
      if weekDaysCount < 7 {
        let emptyDays = Array(repeating: nil, count: 7 - weekDaysCount) as [Day?]
        action(&week, emptyDays)
      }
    }
    
    let weeks: [[Day]] = days.reduce(into: [], { (acc, day) in
      if day.dayOfWeek == 2 || acc.isEmpty {
        acc.append([day])
        return
      }
      acc[acc.index(before: acc.endIndex)].append(day)
    })
  
    var weekWithOptionDays: [[Day?]] = weeks
    addEmptyDays(to: &weekWithOptionDays[0]) { $0.insert(contentsOf: $1, at: 0) }
    addEmptyDays(to: &weekWithOptionDays[weekWithOptionDays.endIndex - 1]) {
      $0.append(contentsOf: $1)
    }
    return weekWithOptionDays
  }
  
  private func generateWeeks(startOfMonth: Date) -> [Day?] {
    var daysOfMonth: [Day] = []
    let daysInMonth = Calendar.current.range(of: .day, in: .month, for: startOfMonth)!
    for day in daysInMonth {
      let date = Calendar.current
        .date(byAdding: .day, value: day - 1, to: startOfMonth)!
      let isToday = Calendar.current.isDateInToday(date)
      let day = Day(
        dayOfMonth: day,
        dayOfWeek: date.dayNumberOfWeek()!,
        isToday: isToday,
        isInPast: !isToday && date < today,
        date: date,
        isLastInMonth: day == daysInMonth.count
      )
      daysOfMonth.append(day)
    }
    return splitDaysByWeeks(daysOfMonth).flatMap { $0 }
  }
  
  private func monthRange(minMonthsToDisplay: Int) -> ClosedRange<Int> {
    guard let fromDate = selectedDateFrom else {
      return 0...minMonthsToDisplay - 1
    }
    let diffInMonth = differenceInMonths(from: today, to: fromDate)
    if diffInMonth < 0 {
      return diffInMonth...minMonthsToDisplay - 1
    }
    return 0...max(diffInMonth, minMonthsToDisplay - 1)
  }
  
  private func generateMonths(minMonthsToDisplay: Int) -> [Month] {
    let dateFormatter = DateFormatter()
    let startOfCurrentMonth = Date().startOfMonth()
    dateFormatter.dateFormat = "LLLL"
    var months: [Month] = []
    for index in monthRange(minMonthsToDisplay: minMonthsToDisplay) {
      let month = Calendar.current
        .date(byAdding: .month, value: index, to: startOfCurrentMonth)!
      let startOfMonth = month.startOfMonth()
      months.append(Month(
        title: dateFormatter.string(from: month),
        distanceFromCurrentMonth: index,
        days: generateWeeks(startOfMonth: startOfMonth)
      ))
    }
    return months
  }
  
  private func feature(for day: Day) -> CalendarDayCell.Feature {
    let isLastInRow = day.isLastInMonth || day.dayOfWeek == 1
    let isFirstInRow = day.dayOfMonth == 1 || day.dayOfWeek == 2
    if isLastInRow && isFirstInRow {
      return .both
    }
    if isFirstInRow { return .firstInRow }
    if isLastInRow { return .lastInRow }
    return .none
  }
  
  private func selectedState(for day: Day) -> CalendarDayCell.SelectedRangeState? {
    guard let from = selectedDateFrom else {
      return nil
    }
    let date = day.date
    guard let to = selectedDateTo else {
      return Calendar.current.isDate(date, equalTo: from, toGranularity: .day)
        ? .single
        : nil
    }
    let isInRange = date.isBetween(from, and: to)
    guard isInRange else { return nil }
    if Calendar.current.isDate(date, equalTo: from, toGranularity: .day) {
      return .lowerBound(feature: feature(for: day))
    }
    if Calendar.current.isDate(date, equalTo: to, toGranularity: .day) {
      return .upperBound(feature: feature(for: day))
    }
    return .insideRange(feature: feature(for: day))
  }
}

extension CalendarDataSource {
  struct Month {
    let title: String
    var distanceFromCurrentMonth: Int
    var days: [Day?]
  }
  struct Day {
    let dayOfMonth: Int
    let dayOfWeek: Int
    let isToday: Bool
    let isInPast: Bool
    let date: Date
    let isLastInMonth: Bool
  }
}

extension CalendarDataSource: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return months.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return months[section].days.count
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    let viewOptional = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: CalendarSectionTitleView.reusableIdentifier,
      for: indexPath
    )
    guard let view = viewOptional as? CalendarSectionTitleView else {
      fatalError("Unexpected reusable view")
    }
    let month = months[indexPath.section]
    view.label.text = month.title
    return view
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cellOptional = collectionView.dequeueReusableCell(
      withReuseIdentifier: CalendarDayCell.reuseIdentifier,
      for: indexPath
    )
    guard let cell = cellOptional as? CalendarDayCell else { fatalError("Unexpected cell") }
    let dayOptional = months[indexPath.section].days[indexPath.item]
    guard let day = dayOptional else { return cell }
    cell.label.text = String(day.dayOfMonth)
    var cellStates: [CalendarDayCell.HighlightState] = []
    if day.isToday { cellStates.append(.today) }
    if let selectState = selectedState(for: day) {
      cellStates.append(.selected(rangeState: selectState))
    }
    cell.states = cellStates
    cell.isInPast = day.isInPast
    return cell
  }
}
