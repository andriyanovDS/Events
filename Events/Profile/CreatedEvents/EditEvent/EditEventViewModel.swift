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
import FirebaseFirestore

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

  func openCalendar() -> Promise<String> {
    let startDate = event.dates.first
    let endDate = event.dates.last
    let selectedDates = startDate == endDate
      ? SelectedDates(from: startDate, to: nil)
      : SelectedDates(from: startDate, to: endDate)

    return Promise { resolve, _ in
      self.steps.accept(EventStep.calendar(
        withSelectedDates: selectedDates,
        onComplete: {[weak self] result in
					guard let self = self else { return }
          if let result = result, result.from != nil {
            self.event.dates = result.dateRange
					}
          resolve(self.event.dateLabelText)
        }
      ))
    }
  }

  func openLocationSearch() {
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
	
	func openEventNameModal() -> Promise<String> {
		let currentEventName = event.name
		return Promise { resolve, _ in
			self.steps.accept(EventStep.eventName(
				initialName: currentEventName,
				onComplete: {[weak self] nameOption in
					guard let self = self, let name = nameOption else {
						resolve(currentEventName)
						return
					}
					self.event.name = name
					resolve(name)
				}
			))
		}
	}
	
	func openDatePicker() -> Promise<String> {
		Promise { resolve, _ in
			self.steps.accept(EventStep.datePickerModal(
				initialDate: self.event.dates.first!,
				mode: .time,
				onComplete: {[weak self] date in
					defer {
						resolve(self?.event.dateLabelText ?? "")
					}
					
					let components = Calendar.current.dateComponents([.hour, .minute], from: date)
					guard let hours = components.hour, let minute = components.minute else { return }
					self?.event.dates
						.enumerated()
						.forEach { (index, date) in
							self?.event.dates[index] = Calendar.current.date(
								bySettingHour: hours,
								minute: minute,
								second: 0,
								of: date
							)!
						}
					
				}
			))
		}
	}
	
	func editEvent() {
		let db = Firestore.firestore()
		let lastUpdatedAt = event.lastUpdateAt
		event.lastUpdateAt = Date()
		
		do {
			try db
			.collection("event-list")
			.document(event.id)
			.setData(from: event, completion: {[weak self] _ in
				self?.closeScreen()
			})
		} catch let error {
			event.lastUpdateAt = lastUpdatedAt
			print(error.localizedDescription)
		}
	}
	
	func closeScreen() {
		steps.accept(EventStep.editEventDidComplete)
	}
}
