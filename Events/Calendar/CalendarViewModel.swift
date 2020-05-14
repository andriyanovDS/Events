//
//  CalendarViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 07/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import RxFlow
import RxSwift
import RxCocoa
import Foundation

class CalendarViewModel: Stepper, ResultProvider {
  let steps = PublishRelay<Step>()
  let onResult: ResultHandler<SelectedDates?>

  init(onResult: @escaping ResultHandler<SelectedDates?>) {
    self.onResult = onResult
  }

  func onClose(with result: SelectedDates?) {
    onResult(result)
    self.steps.accept(EventStep.calendarDidComplete)
  }
}

struct SelectedDates {
  let from: Date?
  let to: Date?

  var label: String? {
    guard let dateFrom = from else {
      return nil
    }
    
    let dateFormatter = DateFormatter()
    if let languageCode = Locale.current.languageCode {
      dateFormatter.locale = Locale(identifier: languageCode)
    }
    dateFormatter.dateFormat = "dd MMMM"
    let dateFromFormatted = dateFormatter.string(from: dateFrom)

    guard let dateTo = to else { return dateFromFormatted }

    let isSameYear = Calendar.current.isDate(dateFrom, equalTo: dateTo, toGranularity: .year)
    if !isSameYear {
      dateFormatter.dateFormat = "dd MMMM YYYY"
    }
    return "\(dateFromFormatted) - \(dateFormatter.string(from: dateTo))"
  }

  var dateRange: [Date] {
    let dateRangeOption = to
      .map { dateRangeCurried(end: $0) }
      .orElse { [$0] }

    return from
      .ap(dateRangeOption)
      .getOrElse(result: [])
  }

  private func dateRangeCurried(end: Date) -> (Date) -> [Date] {
    return { start in
      var dates: [Date] = []
      var date = start

      while date <= end {
        dates.append(date)
        date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
      }
      return dates
    }
  }
}
