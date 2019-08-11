//
//  CreateEventViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift

class CreateEventViewModel {
  let delegate: CreateEventViewModelDelegate
  weak var coordinator: CreateEventCoordinator?
  private let disposeBag = DisposeBag()

  var geocode: Geocode?
  var dates: [Date]
  var duration: EventDurationRange?
  var category: CategoryId?

  lazy var durations = [
    EventDurationRange(min: nil, max: 1),
    EventDurationRange(min: nil, max: 2),
    EventDurationRange(min: 3, max: 5),
    EventDurationRange(min: 5, max: 8),
    EventDurationRange(min: 8, max: nil)
  ]

  init(delegate: CreateEventViewModelDelegate) {
    self.delegate = delegate
    self.dates = generateInitialDates()
    self.duration = durations[0]

    geocodeObserver
      .take(1)
      .subscribe(onNext: { geocode in
        self.geocode = geocode
        self.delegate.setupLocationView(locationName: geocode.fullLocationName())
      })
      .disposed(by: disposeBag)
  }

  func closeScreen() {
    delegate.navigationController?.popViewController(animated: true)
  }

  func openLocationSearchBar() {
    coordinator?.openLocationSearchBar(onResult: { geocode in
      self.geocode = geocode
      self.delegate.onChangeLocationName(geocode.fullLocationName())
    })
  }

  func openCalendar() {
    coordinator?.openCalendar(onResult: { selectedDates in
      selectedDates.from
        .map({ start in selectedDates.to.foldL(
            none: { [start] },
            some: { end in dateRange(start: start, end: end) }
          )
        })
      .foldL(
        none: {
          self.dates = generateInitialDates()
        },
        some: { dates in
          self.dates = dates
      })
      if let foramttedDate = selectedDatesToString(selectedDates) {
        let daysDiff = daysCount(selectedDates: selectedDates)
        self.delegate.onDatesDidSelected(formattedDate: foramttedDate, daysCount: daysDiff)
      }
    })
  }

  func onSelectStartTime(date: Date) {
    let
      hour = Calendar.current.component(.hour, from: date),
      minutes = Calendar.current.component(.minute, from: date)

    dates = dates.map({ v in
      let changedDate = Calendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: v)
      return changedDate.getOrElse(result: v)
    })
  }

  func onSelectEventDuration(_ index: Int) {
    let duration = durations[index]
    duration.foldL(
      none: {},
      some: { v in
        self.duration = v
      }
    )
  }

  func onSelectCategory(id: CategoryId) {
    category = id
  }
}

private func generateInitialDates() -> [Date] {
  let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .init())!
  return [Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow)!]
}

private func dateRange(start: Date, end: Date) -> [Date] {
  var dates: [Date] = []
  var date = start

  while date <= end {
    dates.append(date)
    date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
  }
  return dates
}

private func daysCount(selectedDates: SelectedDates) -> Int {
  guard let dateFrom = selectedDates.from else {
    return 0
  }
  if let dateTo = selectedDates.to {
    return Calendar.current.compare(dateFrom, to: dateTo, toGranularity: .day).rawValue
  }
  return 1
}

private func selectedDatesToString(_ selectedDates: SelectedDates) -> String? {
  guard let dateFrom = selectedDates.from else {
    return nil
  }

  let dateFormatter = DateFormatter()
  dateFormatter.locale = Locale(identifier: "ru_RU")
  dateFormatter.dateFormat = "dd MMMM"

  let dateFromFormatted = dateFormatter.string(from: dateFrom)

  guard let dateTo = selectedDates.to else {
    return dateFromFormatted
  }

  let isSameYear = Calendar.current.isDate(dateFrom, equalTo: dateTo, toGranularity: .year)
  if !isSameYear {
    dateFormatter.dateFormat = "dd MMMM YYYY"
  }
  return "\(dateFromFormatted) - \(dateFormatter.string(from: dateTo))"
}

protocol CreateEventViewModelDelegate: class, UIViewControllerWithActivityIndicator {
  func onChangeLocationName(_: String)
  func setupLocationView(locationName: String)
  func onDatesDidSelected(formattedDate: String, daysCount: Int)
}

protocol CreateEventCoordinator: class {
  func openCalendar(onResult: @escaping (SelectedDates) -> Void)
  func openLocationSearchBar(onResult: @escaping (Geocode) -> Void)
}
