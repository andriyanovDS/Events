//
//  DateViewModel.swift
//  Events
//
//  Created by Dmitry on 09.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import RxCocoa
import RxFlow

class DateViewModel: Stepper {
	let steps = PublishRelay<Step>()
	weak var delegate: DateViewModelDelegate?
	var dates: [Date] = generateInitialDates()
	var duration: EventDurationRange?
	var durations: [EventDurationRange] = [
		EventDurationRange(min: nil, max: 1)!,
    EventDurationRange(min: nil, max: 2)!,
    EventDurationRange(min: 3, max: 5)!,
    EventDurationRange(min: 5, max: 8)!,
    EventDurationRange(min: 8, max: nil)!
	]
	
	init() {
		duration = durations[0]
	}
	
	func openCalendar() {
		 steps.accept(EventStep.calendar(
			 withSelectedDates: SelectedDates(from: nil, to: nil),
			 onComplete: { selectedDates in
				 selectedDates
					 .foldL(
						 none: {},
						 some: { dates in
              let range = dates.dateRange
              self.dates = range.isEmpty
                ? generateInitialDates()
                : range

							 if let foramttedDate = dates.localizedLabel {
								 let daysDiff = daysCount(selectedDates: dates)
								 self.delegate?.onDatesDidSelected(formattedDate: foramttedDate, daysCount: daysDiff)
							 }
						 }
					 )
			 }
		 ))
	 }
	
	func onSelect(date: Date) {
    let
      hour = Calendar.current.component(.hour, from: date),
      minutes = Calendar.current.component(.minute, from: date)

    dates = dates.map({ v in
      let changedDate = Calendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: v)
      return changedDate.getOrElse(result: v)
    })
  }
	
	func onClose() {
		guard let duration = self.duration else {
			fatalError("Duration must be selected")
		}
		delegate?.onResult(DateScreenResult(
			dates: dates,
			duration: duration
		))
		steps.accept(CreateEventStep.dateDidComplete)
	}
}

private func generateInitialDates() -> [Date] {
  let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .init())!
  return [Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: tomorrow)!]
}

private func daysCount(selectedDates: SelectedDates) -> Int {
  guard let dateFrom = selectedDates.from else {
    return 0
  }
  if let dateTo = selectedDates.to {
    return Calendar.current.dateComponents([.day], from: dateFrom, to: dateTo).day!
  }
  return 1
}

struct DateScreenResult {
	let dates: [Date]
	let duration: EventDurationRange
}

protocol DateViewModelDelegate: class {
	var onResult: ((DateScreenResult) -> Void)! { get }
	func onDatesDidSelected(formattedDate: String, daysCount: Int)
}
