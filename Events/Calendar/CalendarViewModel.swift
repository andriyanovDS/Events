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

class CalendarViewModel: Stepper {
  let steps = PublishRelay<Step>()
  var months: [Month]
  weak var delegate: CalendarViewModelDelegate?

  private var selectedDateFrom: Date?
  private var selectedDateTo: Date?
  private let monthsToDisplay = 6

  var selectedDates: SelectedDates {
    SelectedDates(from: selectedDateFrom, to: selectedDateTo)
  }
  
  init(selectedDateFrom: Date?, selectedDateTo: Date?) {
    months = generateMonths(monthsToDisplay: monthsToDisplay)
    self.selectedDateTo = selectedDateTo
    self.selectedDateFrom = selectedDateFrom
  }
  
  func selectDate(selectedDate: Date) {

    defer {
      delegate?.onSelectedDatesDidChange(selectedDates)
    }

    selectedDateFrom
      .foldL(
        none: {
          selectedDateFrom = selectedDate
        },
        some: { dateFrom in
          if dateFrom == selectedDate && selectedDateTo == nil {
            return
          }
          selectedDateTo.foldL(
            none: {
              if dateFrom > selectedDate {
                selectedDateFrom = selectedDate
              } else {
                selectedDateTo = selectedDate
              }
            },
            some: { _ in
              selectedDateFrom = selectedDate
              selectedDateTo = nil
            }
          )
        }
    )
  }
  
  func clearDates() {
    selectedDateTo = nil
    selectedDateFrom = nil
    delegate?.onSelectedDatesDidChange(selectedDates)
  }

  func onClose() {
    self.steps.accept(EventStep.calendarDidComplete)
  }
}

struct SelectedDates {
  let from: Date?
  let to: Date?
}

protocol CalendarViewModelDelegate: class {
  func onSelectedDatesDidChange(_ dates: SelectedDates)
}
