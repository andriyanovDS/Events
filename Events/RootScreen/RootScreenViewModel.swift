//
//  RootScreenViewModel.swift
//  Events
//
//  Created by Дмитрий Андриянов on 08/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import RxSwift

class RootScreenViewModel {

    private var selectedDateFrom: Date?
    private var selectedDateTo: Date?
    private var geocodeDisposable: Disposable?
    private let onChangeLocation: ((String) -> Void)

    init(onChangeLocation: @escaping ((String) -> Void)) {
        self.onChangeLocation = onChangeLocation
        geocodeDisposable = geocodeObserver.subscribe(
            onNext: { [weak self] geocode in
                DispatchQueue.main.async {
                    self?.onChangeLocation(geocode.shortLocationName())
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

    deinit {
        disposeGeocodeSubscription()
    }

    func disposeGeocodeSubscription() {
        geocodeDisposable?.dispose()
        geocodeDisposable = nil
    }
    
    func setSelectedDates(dates: SelectedDates) {
        selectedDateFrom = dates.from
        selectedDateTo = dates.to
    }
    
    func selectedDatesToString() -> String? {
        guard let dateFrom = selectedDateFrom else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        
        let dateFromFormatted = dateFormatter.string(from: dateFrom)
        
        guard let dateTo = selectedDateTo else {
            return dateFromFormatted
        }
        return "\(dateFromFormatted) - \(dateFormatter.string(from: dateTo))"
    }
    
    func getSelectedDates() -> SelectedDates {
        return SelectedDates(from: selectedDateFrom, to: selectedDateTo)
    }

}
