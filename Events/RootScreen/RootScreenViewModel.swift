//
//  RootScreenViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

class RootScreenViewModel: Stepper {
  let steps = PublishRelay<Step>()
  weak var delegate: RootScreenViewModelDelegate?
  private var selectedDateFrom: Date?
  private var selectedDateTo: Date?
  private var geocodeDisposable: Disposable?
  var onChangeLocation: ((String) -> Void)? {
    didSet {
      guard let onChangeLocation = onChangeLocation else {
        return
      }
      geocodeDisposable = geocodeObserver.subscribe(
        onNext: { geocode in
          DispatchQueue.main.async {
            onChangeLocation(geocode.shortLocationName())
          }
        },
        onError: { [weak self] _ in
          self?.disposeGeocodeSubscription()
        },
        onCompleted: { [weak self] in
          self?.disposeGeocodeSubscription()
        },
        onDisposed: nil
      )
    }
  }
  
  deinit {
    disposeGeocodeSubscription()
  }

  func openCalendar() {
    steps.accept(EventStep.calendar(
      withSelectedDates: getSelectedDates(),
      onComplete: { selectedDates in
        self.setSelectedDates(dates: selectedDates)
        self.delegate?.onDatesDidChange(dates: self.selectedDatesToString())
      }
    ))
  }

  func openLocationSearch() {
    steps.accept(EventStep.locationSearch(onResult: { geocode in
      onChangeUserLocation(geocode: geocode)
    }))
  }

  func disposeGeocodeSubscription() {
    geocodeDisposable?.dispose()
    geocodeDisposable = nil
  }
  
  private func selectedDatesToString() -> String? {
    guard let dateFrom = selectedDateFrom else {
      return nil
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ru_RU")
    dateFormatter.dateFormat = "dd MMM"
    
    let dateFromFormatted = dateFormatter.string(from: dateFrom)
    
    guard let dateTo = selectedDateTo else {
      return dateFromFormatted
    }
    return "\(dateFromFormatted) - \(dateFormatter.string(from: dateTo))"
  }

  private func setSelectedDates(dates: SelectedDates) {
    selectedDateFrom = dates.from
    selectedDateTo = dates.to
  }
  
  private func getSelectedDates() -> SelectedDates {
    return SelectedDates(from: selectedDateFrom, to: selectedDateTo)
  }
  
}

protocol RootScreenViewModelDelegate: class {
  func onDatesDidChange(dates: String?)
}
