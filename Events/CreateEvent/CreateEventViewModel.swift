//
//  CreateEventViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import RxFlow
import RxCocoa
import Photos
import Promises

class CreateEventViewModel: Stepper {
  let steps = PublishRelay<Step>()
  var geocode: Geocode?
  var dates: [Date] = []
  var duration: EventDurationRange?
  var category: CategoryId?
  var descriptions: [Description] = []

  func closeScreen() {
    steps.accept(EventStep.createEventDidComplete)
  }
	
	func createEvent() {
		
	}

  func locationDidSelected(geocode: Geocode) {
    self.geocode = geocode
    openDateScreen()
  }

  func onClose() {
    steps.accept(EventStep.createEventDidComplete)
  }

  func openDateScreen() {
    steps.accept(CreateEventStep.date(onResult: {[weak self] result in
      self?.dates = result.dates
      self?.duration = result.duration
      self?.openCategoryScreen()
    }))
  }

  private func openCategoryScreen() {
    steps.accept(CreateEventStep.category(onResult: {[weak self] categoryId in
      self?.category = categoryId
      self?.openDescriptionScreen()
    }))
  }

  private func openDescriptionScreen() {
     steps.accept(CreateEventStep.description(onResult: {[weak self] descriptions in
       self?.descriptions = descriptions
     }))
   }
}
