//
//  EditEventViewModel.swift
//  Events
//
//  Created by Dmitry on 03.04.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxFlow
import RxCocoa
import Promises

class EditEventViewModel: Stepper {
	var event: Event
	let steps = PublishRelay<Step>()
	
	init(event: Event) {
		self.event = event
	}

  private struct CategoryListButton: ListModalButton {
    let labelText: String
    let value: CategoryId
    let isSelected: Bool
  }

  func toogleEventAccess() {
    event.isPublic = !event.isPublic
  }

  func openCategoryListModal() -> Promise<CategoryId> {
    let buttons = CategoryId.allCases.map {
      CategoryListButton(
        labelText: $0.translatedLabel(),
        value: $0,
        isSelected: event.categories.contains($0)
      )
    }
    return Promise { resolve, _ in
      self.steps.accept(EventStep.listModal(
        title: NSLocalizedString(
          "Select Category",
          comment: "Edit event: category list modal title"
        ),
        buttons: buttons,
        onComplete: {[weak self] selectedButton in
          guard let button = selectedButton as? CategoryListButton else {
            fatalError("Unexpected button")
          }
          self?.event.categories = [button.value]
          resolve(button.value)
        }
      ))
    }
  }

  func openCalendar() -> Promise<Date> {
    let startDate = event.dates.first
    let endDate = event.dates.last
    let selectedDates = startDate == endDate
      ? SelectedDates(from: startDate, to: nil)
      : SelectedDates(from: startDate, to: endDate)

    return Promise { resolve, _ in
      self.steps.accept(EventStep.calendar(
        withSelectedDates: selectedDates,
        onComplete: {[weak self] result in
          if let result = result, let dateFrom = result.from {
            self?.event.dates = result.dateRange
            resolve(dateFrom)
            return
          }
          let dateFrom = Date()
          self?.event.dates = [dateFrom]
          resolve(dateFrom)
        }
      ))
    }
  }

  func openLocationSearch(){
   self.steps.accept(EventStep.locationSearch(
      onResult: {[weak self] result in
        self?.event.location = EventLocation(
          lat: result.geometry.location.lat,
          lng: result.geometry.location.lng,
          fullName: result.fullLocationName()
        )
      }
    ))
  }
	
	func closeScreen() {
		steps.accept(EventStep.editEventDidComplete)
	}
}
